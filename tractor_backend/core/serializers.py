from rest_framework import serializers
from .models import Tractor, Equipment, Booking, Review


# ===============================
# 🛠 EQUIPMENT SERIALIZER
# ===============================
class EquipmentSerializer(serializers.ModelSerializer):
    class Meta:
        model = Equipment
        fields = "__all__"


# ===============================
# 🚜 TRACTOR SERIALIZER
# (Includes equipments)
# ===============================
class TractorSerializer(serializers.ModelSerializer):
    # ✅ Nested equipments (used in MyTractorsScreen)
    equipments = EquipmentSerializer(many=True, read_only=True)

    class Meta:
        model = Tractor
        fields = "__all__"


# ===============================
# 📅 BOOKING SERIALIZER
# (Flutter dashboard compatible)
# ===============================
class BookingSerializer(serializers.ModelSerializer):
    # ✅ Used in upcoming bookings & dashboard UI
    tractor_name = serializers.CharField(
        source="tractor.name",
        read_only=True,
    )

    class Meta:
        model = Booking
        fields = "__all__"


# ===============================
# ⭐ REVIEW SERIALIZER
# ===============================
class ReviewSerializer(serializers.ModelSerializer):
    class Meta:
        model = Review
        fields = "__all__"
