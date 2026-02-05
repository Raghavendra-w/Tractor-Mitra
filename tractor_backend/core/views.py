from rest_framework.decorators import api_view
from rest_framework.response import Response
from rest_framework import status
from django.utils import timezone
from django.db.models import Sum
from datetime import timedelta
import random

from .models import Owner, Tractor, Equipment, Booking, Review
from .serializers import (
    TractorSerializer,
    EquipmentSerializer,
    BookingSerializer,
    ReviewSerializer,
)

# ==================================================
# 🚜 LIST TRACTORS (CATEGORY + AVAILABLE)
# ==================================================
@api_view(["GET"])
def tractor_list(request):
    category = request.GET.get("category")
    tractors = Tractor.objects.filter(available=True)

    if category:
        tractors = tractors.filter(category=category)

    serializer = TractorSerializer(tractors, many=True)
    return Response(serializer.data, status=status.HTTP_200_OK)


# ==================================================
# ➕ ADD TRACTOR (OWNER REQUIRED)
# (MERGED FROM OLD + NEW)
# ==================================================
@api_view(["POST"])
def add_tractor(request):
    owner_id = request.data.get("owner")

    if not owner_id:
        return Response(
            {"error": "Owner required"},
            status=status.HTTP_400_BAD_REQUEST,
        )

    serializer = TractorSerializer(data=request.data)
    if serializer.is_valid():
        serializer.save(owner_id=owner_id)
        return Response(serializer.data, status=status.HTTP_201_CREATED)

    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


# ==================================================
# 🚜 GET OWNER TRACTORS (Vehicles Tab) ✅
# ==================================================
@api_view(["GET"])
def owner_tractors(request, owner_id):
    tractors = Tractor.objects.filter(owner_id=owner_id)
    serializer = TractorSerializer(tractors, many=True)
    return Response(serializer.data, status=status.HTTP_200_OK)


# ==================================================
# 🔁 TOGGLE TRACTOR AVAILABILITY (ON / OFF) ✅
# (MERGED OLD + NEW)
# ==================================================
@api_view(["POST"])
def toggle_availability(request):
    tractor_id = request.data.get("tractorId")
    available = request.data.get("available", True)

    try:
        tractor = Tractor.objects.get(id=tractor_id)
        tractor.available = available
        tractor.save()

        return Response(
            {
                "message": "Availability updated",
                "available": tractor.available,
            },
            status=status.HTTP_200_OK,
        )

    except Tractor.DoesNotExist:
        return Response(
            {"error": "Tractor not found"},
            status=status.HTTP_404_NOT_FOUND,
        )


# ==================================================
# 🛠 ADD EQUIPMENT
# ==================================================
@api_view(["POST"])
def add_equipment(request):
    serializer = EquipmentSerializer(data=request.data)

    if serializer.is_valid():
        serializer.save()
        return Response(serializer.data, status=status.HTTP_201_CREATED)

    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


# ==================================================
# 📅 LIST BOOKINGS
# ==================================================
@api_view(["GET"])
def booking_list(request):
    bookings = Booking.objects.all().order_by("-created_at")
    serializer = BookingSerializer(bookings, many=True)
    return Response(serializer.data, status=status.HTTP_200_OK)


# ==================================================
# 📅 CREATE BOOKING
# ==================================================
@api_view(["POST"])
def create_booking(request):
    serializer = BookingSerializer(data=request.data)

    if serializer.is_valid():
        tractor = serializer.validated_data["tractor"]

        if not tractor.available:
            return Response(
                {"error": "Vehicle not available"},
                status=status.HTTP_400_BAD_REQUEST,
            )

        booking = serializer.save()
        tractor.available = False
        tractor.save()

        return Response(serializer.data, status=status.HTTP_201_CREATED)

    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


# ==================================================
# ✅ COMPLETE BOOKING
# ==================================================
@api_view(["POST"])
def complete_booking(request, booking_id):
    try:
        booking = Booking.objects.get(id=booking_id)

        booking.completed = True
        booking.completed_at = timezone.now()
        booking.save()

        tractor = booking.tractor
        tractor.available = True
        tractor.save()

        return Response(
            {"message": "Booking completed successfully"},
            status=status.HTTP_200_OK,
        )

    except Booking.DoesNotExist:
        return Response(
            {"error": "Booking not found"},
            status=status.HTTP_404_NOT_FOUND,
        )


# ==================================================
# 📊 WEEKLY BOOKING STATS (OWNER DASHBOARD)
# ==================================================
@api_view(["GET"])
def weekly_booking_stats(request, owner_id):
    today = timezone.now().date()
    start = today - timedelta(days=6)

    received = [0] * 7
    accepted = [0] * 7

    bookings = Booking.objects.filter(
        tractor__owner_id=owner_id,
        created_at__date__gte=start,
    )

    for b in bookings:
        index = (b.created_at.date() - start).days
        if 0 <= index < 7:
            received[index] += 1
            if b.completed:
                accepted[index] += 1

    return Response(
        {
            "days": ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"],
            "received": received,
            "accepted": accepted,
        },
        status=status.HTTP_200_OK,
    )


# ==================================================
# 💰 TOTAL EARNINGS (OWNER DASHBOARD)
# ==================================================
@api_view(["GET"])
def owner_total_earnings(request, owner_id):
    completed_bookings = Booking.objects.filter(
        tractor__owner_id=owner_id,
        completed=True,
    )

    total_earning = completed_bookings.aggregate(
        total=Sum("total_price")
    )["total"] or 0

    completed_jobs = completed_bookings.count()

    return Response(
        {
            "total_earning": total_earning,
            "completed_jobs": completed_jobs,
        },
        status=status.HTTP_200_OK,
    )


# ==================================================
# 📅 UPCOMING BOOKINGS (OWNER DASHBOARD)
# ==================================================
@api_view(["GET"])
def owner_upcoming_bookings(request, owner_id):
    bookings = Booking.objects.filter(
        tractor__owner_id=owner_id,
        completed=False,
    ).order_by("-created_at")

    data = [
        {
            "id": b.id,
            "tractor_name": b.tractor.name,
            "hours": b.hours,
            "total_price": b.total_price,
            "created_at": b.created_at.strftime("%d %b %Y"),
        }
        for b in bookings
    ]

    return Response(data, status=status.HTTP_200_OK)


# ==================================================
# ⭐ LIST REVIEWS
# ==================================================
@api_view(["GET"])
def review_list(request, tractor_id):
    reviews = Review.objects.filter(tractor_id=tractor_id)
    serializer = ReviewSerializer(reviews, many=True)
    return Response(serializer.data, status=status.HTTP_200_OK)


# ==================================================
# ✍️ ADD REVIEW
# ==================================================
@api_view(["POST"])
def add_review(request):
    serializer = ReviewSerializer(data=request.data)

    if serializer.is_valid():
        serializer.save()
        return Response(serializer.data, status=status.HTTP_201_CREATED)

    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


# ==================================================
# 🔐 SEND OTP
# ==================================================
@api_view(["POST"])
def send_otp(request):
    mobile = request.data.get("mobile")

    if not mobile:
        return Response(
            {"error": "Mobile number required"},
            status=status.HTTP_400_BAD_REQUEST,
        )

    otp = str(random.randint(100000, 999999))
    owner, _ = Owner.objects.get_or_create(mobile=mobile)
    owner.otp = otp
    owner.otp_created_at = timezone.now()
    owner.save()

    print(f"OTP for {mobile} is {otp}")  # replace with SMS gateway

    return Response(
        {"message": "OTP sent successfully"},
        status=status.HTTP_200_OK,
    )


# ==================================================
# 🔐 VERIFY OTP
# ==================================================
@api_view(["POST"])
def verify_otp(request):
    mobile = request.data.get("mobile")
    otp = request.data.get("otp")

    if not mobile or not otp:
        return Response(
            {"error": "Mobile and OTP required"},
            status=status.HTTP_400_BAD_REQUEST,
        )

    try:
        owner = Owner.objects.get(mobile=mobile)

        if owner.otp != otp:
            return Response(
                {"error": "Invalid OTP"},
                status=status.HTTP_400_BAD_REQUEST,
            )

        owner.otp = None
        owner.save()

        return Response(
            {
                "message": "Login successful",
                "owner_id": owner.id,
                "mobile": owner.mobile,
            },
            status=status.HTTP_200_OK,
        )

    except Owner.DoesNotExist:
        return Response(
            {"error": "Owner not found"},
            status=status.HTTP_404_NOT_FOUND,
        )
@api_view(["PATCH"])
def toggle_tractor_availability(request, tractor_id):
    try:
        tractor = Tractor.objects.get(id=tractor_id)
        tractor.available = request.data.get("available", tractor.available)
        tractor.save()

        return Response(
            {"message": "Availability updated", "available": tractor.available},
            status=status.HTTP_200_OK
        )
    except Tractor.DoesNotExist:
        return Response(
            {"error": "Tractor not found"},
            status=status.HTTP_404_NOT_FOUND
        )
@api_view(["GET"])
def owner_profile(request):
    owner = request.user.owner
    return Response({
        "name": owner.name,
        "phone": owner.phone,
        "email": owner.email,
        "address": owner.address,
        "image": owner.image.url if owner.image else None
    })


@api_view(["GET", "POST"])
def owner_preferences(request):
    owner = request.user.owner

    if request.method == "POST":
        owner.notifications = request.data.get("notifications", True)
        owner.save()

    return Response({
        "notifications": owner.notifications
    })
# ==================================================
# 👤 OWNER PROFILE (GET BY owner_id) ✅ MERGED
# ==================================================
@api_view(["GET"])
def owner_profile(request):
    owner_id = request.GET.get("owner_id")

    if not owner_id:
        return Response(
            {"error": "owner_id is required"},
            status=status.HTTP_400_BAD_REQUEST,
        )

    try:
        owner = Owner.objects.get(id=owner_id)
    except Owner.DoesNotExist:
        return Response(
            {"error": "Owner not found"},
            status=status.HTTP_404_NOT_FOUND,
        )

    return Response(
        {
            "id": owner.id,
            "name": owner.name,
            "mobile": owner.mobile,
            "email": owner.email,
            "district": owner.district,
            "state": owner.state,
            "address": owner.address,
            "profile_image": owner.profile_image.url
            if owner.profile_image
            else None,
            "created_at": owner.created_at,
        },
        status=status.HTTP_200_OK,
    )
@api_view(["GET"])
def owner_notifications(request, owner_id):
    # For now, static or empty list
    return Response([])
@api_view(['POST'])
def add_tractor(request):
    owner_id = request.data.get("owner_id")

    if not owner_id:
        return Response(
            {"error": "Owner ID required"},
            status=400
        )

    owner = Owner.objects.get(id=owner_id)

    tractor = Tractor.objects.create(
        owner=owner,
        name=request.data.get("name"),
        model=request.data.get("model"),
        year=request.data.get("year"),
        registration_number=request.data.get("registration_number"),
        owner_name=request.data.get("owner_name"),
        chassis_number=request.data.get("chassis_number"),
        insured=request.data.get("insured", False),
        price_per_hour=request.data.get("price"),
        available=request.data.get("available", True),
    )

    return Response({"success": True}, status=201)

