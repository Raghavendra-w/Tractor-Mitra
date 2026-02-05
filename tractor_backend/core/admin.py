from django.contrib import admin
from .models import Tractor, Booking


@admin.register(Tractor)
class TractorAdmin(admin.ModelAdmin):
    list_display = ('id', 'name', 'price_per_hour', 'available')
    list_filter = ('available',)
    search_fields = ('name',)


@admin.register(Booking)
class BookingAdmin(admin.ModelAdmin):
    list_display = ('id', 'tractor', 'hours', 'total_price', 'created_at')
    list_filter = ('created_at',)
    search_fields = ('tractor__name',)
