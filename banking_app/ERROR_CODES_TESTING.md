# Transfer Error Codes - Testing Guide

## 🧪 How to Test Transfer Errors

To simulate transfer errors in the banking app, simply enter one of the error codes below as the **Beneficiary Name** when creating a transfer.

## 📋 Available Error Codes

### 🔐 Authentication & Authorization Errors
- **AUTH001** - Authentication Error
- **AUTH002** - Authorization Error  
- **SES001** - Session Expired

### 🌐 Network & Server Errors
- **NET001** - Connection Error (Retryable)
- **SRV001** - Server Unavailable (Retryable)
- **TIM001** - Request Timeout (Retryable)
- **SRV002** - Transfer Service Unavailable (Retryable)

### ❌ Validation & Format Errors
- **VAL001** - Data Validation Error
- **ACC001** - Invalid Account Format
- **AMT001** - Invalid Amount
- **BEN001** - Invalid Beneficiary

### 💰 Financial Errors
- **BAL001** - Insufficient Funds
- **LIM001** - Transfer Limit Exceeded
- **ACC002** - Account Blocked

### 🔄 Transaction Errors
- **DUP001** - Duplicate Transaction
- **INT001** - Internal Application Error (Retryable)

## 🎯 Testing Instructions

1. **Start a new transfer** from the dashboard
2. **Fill in Step 1** with any valid information EXCEPT:
   - **Beneficiary Name**: Enter one of the error codes above (e.g., "AUTH001")
3. **Complete Steps 2-4** normally
4. **Confirm the transfer** - it will simulate the error after 3 seconds of loading
5. **Observe the error screen** with specific details for that error type

## 📊 Error Screen Features

Each error screen shows:
- ✅ **Animated error icon** with specific emoji
- ✅ **Error details** (code, category, description)
- ✅ **Failed transfer summary**
- ✅ **Resolution suggestions** (when available)
- ✅ **Retry button** (for retryable errors only)
- ✅ **Contact support** options
- ✅ **Obsly tracking** with error-specific tags

## 🎨 Error Color Coding

- **🔴 Red**: Critical errors (auth, blocked accounts)
- **🟠 Orange**: Network/server issues
- **🟡 Yellow**: Financial constraints (insufficient funds, limits)
- **🔴 Red (default)**: Other errors

## 💡 Demo Tips

- Use **NET001** or **SRV001** to show retryable errors
- Use **BAL001** to demonstrate financial validation
- Use **AUTH001** to show security scenarios
- Use **INT001** for general technical issues
