from django.db import models
from django.utils import timezone


# ==================================================
# 👤 OWNER MODEL (MERGED – SAFE)
# ==================================================
class Owner(models.Model):
    # 🔹 Basic identity (old + new)
    name = models.CharField(max_length=100, blank=True)
    mobile = models.CharField(max_length=15, unique=True)
    phone = models.CharField(max_length=15, blank=True, null=True)

    email = models.EmailField(blank=True, null=True)

    # 🔹 OTP AUTH
    otp = models.CharField(max_length=6, blank=True, null=True)
    otp_created_at = models.DateTimeField(blank=True, null=True)

    # 🔹 Address / profile
    location = models.TextField(blank=True)
    address = models.TextField(blank=True)
    district = models.CharField(max_length=100, blank=True)
    state = models.CharField(max_length=100, blank=True)

    profile_image = models.ImageField(
        upload_to="owners/",
        blank=True,
        null=True,
    )

    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return self.mobile or self.name


# ==================================================
# 🚜 TRACTOR MODEL (FULLY MERGED)
# ==================================================
class Tractor(models.Model):
    CATEGORY_CHOICES = [
        ("tractor", "Tractor"),
        ("harvester", "Harvester"),
        ("jcb", "JCB"),
        ("trolley", "Trolley"),
    ]

    owner = models.ForeignKey(
        Owner,
        related_name="tractors",
        on_delete=models.CASCADE,
        null=True,
        blank=True,
    )

    # 🔹 OLD VEHICLE FIELDS (KEPT)
    vehicle_type = models.CharField(max_length=50, blank=True)
    year = models.CharField(max_length=10, blank=True)
    registration_number = models.CharField(max_length=50, blank=True)
    owner_name = models.CharField(max_length=100, blank=True)
    chassis_number = models.CharField(max_length=100, blank=True)
    insured = models.BooleanField(default=True)

    price = models.IntegerField(null=True, blank=True)
    unit = models.CharField(max_length=20, blank=True)

    # 🔹 NEW / ACTIVE FIELDS
    name = models.CharField(max_length=100)
    brand = models.CharField(max_length=100, blank=True)
    model = models.CharField(max_length=100, blank=True)
    horsepower = models.IntegerField(null=True, blank=True)
    condition = models.CharField(max_length=50, blank=True)

    category = models.CharField(
        max_length=20,
        choices=CATEGORY_CHOICES,
        default="tractor",
    )

    price_per_hour = models.IntegerField(null=True, blank=True)
    available = models.BooleanField(default=True)

    image = models.ImageField(
        upload_to="tractors/",
        null=True,
        blank=True,
    )

    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return self.name


# ==================================================
# 🧰 EQUIPMENT MODEL (UNCHANGED + SAFE)
# ==================================================
class Equipment(models.Model):
    tractor = models.ForeignKey(
        "Tractor",
        related_name="equipments",
        on_delete=models.CASCADE,
    )

    name = models.CharField(max_length=100)
    price_per_hour = models.IntegerField()
    image = models.ImageField(
        upload_to="equipments/",
        null=True,
        blank=True,
    )

    def __str__(self):
        return f"{self.name} ({self.tractor.name})"


# ==================================================
# 📅 BOOKING MODEL (MERGED + DASHBOARD READY)
# ==================================================
class Booking(models.Model):
    tractor = models.ForeignKey(
        "Tractor",
        on_delete=models.CASCADE,
    )

    hours = models.IntegerField()
    total_price = models.IntegerField()

    completed = models.BooleanField(default=False)
    completed_at = models.DateTimeField(null=True, blank=True)

    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.tractor.name} - ₹{self.total_price}"


# ==================================================
# ⭐ REVIEW MODEL (KEPT)
# ==================================================
class Review(models.Model):
    tractor = models.ForeignKey(
        "Tractor",
        related_name="reviews",
        on_delete=models.CASCADE,
    )

    rating = models.IntegerField()
    comment = models.TextField()

    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.tractor.name} - {self.rating}"
    
