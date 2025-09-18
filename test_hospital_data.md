# Test Hospital Registration

To test the hospital approval system, use these sample hospital details:

## Hospital 1:
- Hospital Name: Dhaka Medical College Hospital
- Email: dmch@test.com
- Password: test123456
- Phone: +8801712345678
- License Number: DMCH-2024-001
- Address: Dhaka, Bangladesh

## Hospital 2:
- Hospital Name: Square Hospital
- Email: square@test.com
- Password: test123456
- Phone: +8801812345678
- License Number: SH-2024-002
- Address: Panthapath, Dhaka

## Admin Login:
- Email: admin@gmail.com
- Password: 123456

## Testing Steps:
1. Register hospitals using the registration form
2. Try to login with hospital credentials (should be blocked)
3. Login as admin
4. Go to Hospital Approvals section
5. Approve hospitals
6. Hospital should now be able to login

## Expected Behavior:
- Hospitals register with "pending" status
- Cannot login until approved by admin
- Admin can see all pending hospitals
- After approval, hospitals can login normally
