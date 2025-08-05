# Bazario – Design Document

## Overview

**Bazario** is a web-based multi-category marketplace platform that connects Sellers and Buyers. The app supports a wide range of product categories including food, scrap items, electronic spare parts, and waste materials. It includes three user roles:

* Buyer
* Seller
* Admin

The application is built using:

* **Frontend**: React.js
* **Backend**: Flask (Python)
* **Database**: PostgreSQL

---

## Functional Requirements

### 1. Authentication & Authorization

* Role-based login: Buyer / Seller / Admin
* Email-based registration and OTP verification
* Login via password and OTP confirmation

**Register Form:**

* Name
* Email ID
* Password
* Re-enter Password
* Role (Buyer / Seller)

**OTP Flow:**

* After registration/login, user receives OTP on email
* Correct OTP: redirect to respective home page
* Incorrect OTP: show error message

**Login Form:**

* Email ID / Username
* Password
* Role (Buyer / Seller)
* OTP Confirmation

---

### 2. Seller Flow

#### Seller Onboarding

* Name
* Point of Contact (Phone Number, Email ID)
* Address:

  * Flat No, Door No, Plot No
  * Address Line 1
  * Address Line 2
  * Pincode

#### Create Menu / Request

* Item Type: Dropdown list

  * Food
  * Plastic Bottles
  * Newspapers
  * Spare Parts (Electronics)
  * Dry/Wet Waste Bin
* Quantity (KGs)
* Image Upload
* Description
* Price (INR)
* Preferred Pickup Date
* Preferred Time Slot

#### Seller Dashboard

* View list of all created seller requests
* For each request:

  * Buyer interactions (bid list)
  * Accept / Decline buyer bids

    * On Decline: capture reason

---

### 3. Buyer Flow

#### Buyer Dashboard

* List all available seller requests
* Filters:

  * Item Type
  * Preferred Date & Time
  * Price Range
  * Quantity

#### Seller Card View

* Seller Info
* Contact Details
* Item Type
* Quantity
* Price
* "Purchase" button to bid (enter proposed price)

#### Bid Flow

* Submit bid to Seller
* Notify Buyer ("Seller has been notified")
* Email Notification to Seller about new Buyer interest

#### Buyer Order History

* List of all accepted buyer orders

  * Seller ID
  * Item Type
  * Quantity
  * Price
  * Rating
  * Feedback
  * Date/Time

---

### 4. Admin Dashboard

* View all users (Buyers / Sellers)
* Manage requests
* View transaction history
* View complaints/feedback
* Moderate spam or fraud

---

### 5. Order History

* Maintain transactional history between buyers and sellers
* Store:

  * Seller ID
  * Buyer ID
  * Item Type
  * Quantity
  * Final Agreed Price
  * Date/Time
  * Status (Pending/Completed)

---

### 6. User Settings

* Edit Profile
* Change Password
* Logout

---

## Technology Stack

* React (Vite, React Router, Axios, Context API)
* Flask (JWT Auth, Flask-Mail, Flask-Migrate, Flask-CORS)
* PostgreSQL (SQLAlchemy ORM)
* Email Service (SMTP or SendGrid)

---

## Future Enhancements

* Chat feature between buyer and seller
* Admin analytics dashboard
* Push notifications
* Geolocation filter for hyperlocal browsing
* Payment Integration
* Wishlist
* Mobile no. OTP Authentcation
* Android and IOS App
* In App Messaging

---

## Summary

Bazario is designed to be a flexible, category-agnostic, and intuitive marketplace for buying and selling a diverse range of goods and scrap. It provides an efficient bridge between sellers and buyers, while empowering admins with monitoring and control functionalities.