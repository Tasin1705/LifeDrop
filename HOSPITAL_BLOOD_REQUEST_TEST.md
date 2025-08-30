# Hospital Blood Request Testing Guide

## 🏥 **Hospital Dashboard Blood Request Testing**

### **What I've Implemented:**

✅ **Enhanced Hospital Blood Request Dialog** with:
- Blood type selection (A+, A-, B+, B-, AB+, AB-, O+, O-)
- Units required (with validation)
- Contact number field
- Required date picker
- Hospital location field
- Urgency level (Low, Medium, High, Critical)
- Full integration with notification system

✅ **Notification System Integration**:
- Automatically finds donors with matching blood type
- Checks donor eligibility (3-month countdown rule)
- Sends notifications only to eligible donors
- Stores request in Firestore database

### **Testing Steps:**

#### **Step 1: Access Hospital Dashboard**
1. **Login as a Hospital** account
2. **Navigate to Hospital Dashboard**
3. **Click on "Requests" tab** in the sidebar

#### **Step 2: Create Blood Request**
1. **Click "New Request" button** (top right)
2. **Fill out the form**:
   - Select blood type (e.g., O+)
   - Enter units required (e.g., 2)
   - Enter contact number
   - Click calendar to select required date
   - Enter hospital location
   - Select urgency level
3. **Click "Create Request"**

#### **Step 3: Verify Notifications**
1. **Check loading dialog** - shows "Creating..."
2. **Look for success message** - "Blood request created! X eligible donors notified"
3. **Switch to donor account** with matching blood type
4. **Check donor dashboard** - notification bell should show count
5. **Click notification bell** - should see blood request notification

### **Expected Behavior:**

#### **For Hospital:**
- ✅ Form validation works (required fields)
- ✅ Loading indicator during submission
- ✅ Success message with count of notified donors
- ✅ Request stored in database

#### **For Eligible Donors:**
- ✅ Notification appears in real-time
- ✅ Notification bell shows unread count
- ✅ Notification contains all request details:
  - Blood type needed
  - Units required
  - Contact information
  - Required date
  - Hospital name

#### **For Ineligible Donors:**
- ✅ No notification received (if donated within 3 months)
- ✅ Only eligible donors are contacted

### **Test Scenarios:**

#### **Scenario 1: Multiple Eligible Donors**
1. **Create 3 donor accounts** with O+ blood type
2. **Set different last donation dates**:
   - Donor 1: No previous donation (eligible)
   - Donor 2: Donated 4 months ago (eligible)
   - Donor 3: Donated 1 month ago (ineligible)
3. **Hospital requests O+ blood**
4. **Expected**: Only Donors 1 & 2 receive notifications

#### **Scenario 2: No Eligible Donors**
1. **All O+ donors donated recently** (within 3 months)
2. **Hospital requests O+ blood**
3. **Expected**: "0 eligible donors notified" message

#### **Scenario 3: Different Blood Types**
1. **Hospital requests A+ blood**
2. **Only A+ donors** should receive notifications
3. **O+, B+, AB+ donors** should not receive notifications

### **Debugging:**

If notifications don't work:
1. **Check Firestore rules** are applied correctly
2. **Verify donor eligibility** (check lastDonation dates)
3. **Check console** for any error messages
4. **Verify hospital authentication** is working

### **Database Structure:**

**Blood Requests Collection:**
```
/blood_requests/{requestId}
  - bloodType: "O+"
  - units: "2"
  - contact: "+1234567890"
  - requiredDate: Timestamp
  - urgency: "High"
  - location: "City Hospital, Main St"
  - requesterName: "City Hospital"
  - requesterType: "Hospital"
  - requesterId: "hospital_user_id"
  - notifiedDonors: ["donor1_id", "donor2_id"]
  - createdAt: Timestamp
  - status: "active"
```

**Notifications Collection:**
```
/notifications/{notificationId}
  - userId: "donor_user_id"
  - title: "Blood Request - O+"
  - message: "Hospital needs 2 units of O+ blood..."
  - type: "blood_request"
  - data: {blood request details}
  - isRead: false
  - createdAt: Timestamp
```

The system is now fully functional for hospital blood requests with real-time notifications to eligible donors!
