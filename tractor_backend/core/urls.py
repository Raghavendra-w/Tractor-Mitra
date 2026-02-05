from django.urls import path
from .views import (
    # =========================
    # 🚜 TRACTORS
    # =========================
    tractor_list,
    add_tractor,
    owner_tractors,
    toggle_availability,
    owner_profile,
    owner_preferences,

    # =========================
    # 🛠 EQUIPMENTS
    # =========================
    add_equipment,

    # =========================
    # 📅 BOOKINGS
    # =========================
    booking_list,
    create_booking,
    complete_booking,
    weekly_booking_stats,
    owner_upcoming_bookings,
    owner_total_earnings,
    owner_notifications,

    # =========================
    # ⭐ REVIEWS
    # =========================
    review_list,
    add_review,

    # =========================
    # 🔐 OWNER AUTH (OTP)
    # =========================
    send_otp,
    verify_otp,
)

urlpatterns = [
    # ==================================================
    # 🚜 TRACTORS
    # ==================================================
    path("tractors/", tractor_list),
    path("tractors/add/", add_tractor),

    # 🔁 OWNER TRACTORS (OLD + NEW)
    path("tractor/<int:owner_id>/", owner_tractors),          # legacy
    path("owners/<int:owner_id>/tractors/", owner_tractors),  # new

    # 🔄 TOGGLE AVAILABILITY
    path("tractor/toggle/", toggle_availability),             # legacy-safe

    # ==================================================
    # 🛠 EQUIPMENTS
    # ==================================================
    path("equipment/add/", add_equipment),     # legacy
    path("equipments/add/", add_equipment),    # new
    
    # ==================================================
    # 📅 BOOKINGS
    # ==================================================
    path("bookings/", booking_list),
    path("bookings/create/", create_booking),
    path("bookings/complete/<int:booking_id>/", complete_booking),

    # ==================================================
    # 📊 OWNER DASHBOARD
    # ==================================================
    path(
        "dashboard/<int:owner_id>/stats/",
        owner_total_earnings,                  # legacy dashboard stats
    ),
    path(
        "owners/<int:owner_id>/total-earnings/",
        owner_total_earnings,                  # new
    ),
    path(
        "owners/<int:owner_id>/weekly-stats/",
        weekly_booking_stats,
    ),
    path(
        "dashboard/<int:owner_id>/upcoming/",
        owner_upcoming_bookings,               # legacy
    ),
    path(
        "owners/<int:owner_id>/upcoming-bookings/",
        owner_upcoming_bookings,               # new
    ),
    path("owner/profile/", owner_profile),
    path("owner/preferences/", owner_preferences),
    


    # ==================================================
    # ⭐ REVIEWS
    # ==================================================
    path("reviews/<int:tractor_id>/", review_list),
    path("reviews/add/", add_review),
    path("owners/<int:owner_id>/notifications/", owner_notifications),


    # ==================================================
    # 🔐 OWNER AUTH (OTP)
    # ==================================================
    path("send-otp/", send_otp),
    path("verify-otp/", verify_otp),
]
