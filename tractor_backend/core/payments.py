import razorpay

client = razorpay.Client(
    auth=("rzp_test_xxxxx", "rzp_test_secret")
)

def create_order(amount):
    order = client.order.create({
        "amount": amount * 100,  # ₹ → paise
        "currency": "INR",
        "payment_capture": 1
    })
    return order
