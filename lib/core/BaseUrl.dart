class BaseUrl {
  static const String base_url="https://pcsdecom.azurewebsites.net";
  static const String baseurl_api="$base_url/api";
  static const String login="$baseurl_api/Auth/login";



  static const String verifyEmail =
      "$baseurl_api/Auth/verify-email";

  static const String medicines =
      "$baseurl_api/discovery/medicines?page=1&pageSize=20";

  static const String registerCustomer =
      "$baseurl_api/Auth/register/customer";

  //Image and text one
  static const String customerOrderReview =
      "$baseurl_api/customer/orders/review";


  //for referral code
  static const String referralInfo =
      "$baseurl_api/Referral/my-referral-info";

  //Post
  // order from menu
  static const String customerOrders =
      "$baseurl_api/customer/orders";

  //For Customer History
  static const String customerHistory =
      "$baseurl_api/customer/orders/get";

  //For Change Password
  static const String changePassword =
      "$baseurl_api/Auth/change-password";

  static const String forgotPassword =
      "$baseurl_api/Auth/forgot-password"; 

  static const String resetPassword =
      "$baseurl_api/Auth/reset-password";

  //Edit user information(PUT API)
  static const String customerProfile =
      "$baseurl_api/Auth/customer/profile";

  // Added Category API
  static const String medicineCategories = "$baseurl_api/discovery/categories/medicine";

  static String getMedicinesByCategory(String categoryId) =>
      "$baseurl_api/discovery/medicines/category/$categoryId";

  // --- Cancel Order API ---
  static String cancelOrder(String orderId) =>
      "$baseurl_api/customer/orders/$orderId/cancel";

  // For Food
  //trending one
  static const String trendingFoods = "$baseurl_api/discovery/menu-items/trending?limit=10";

   // food displayed in menu
  static const String allFoodItems = "$baseurl_api/discovery/menu-items?page=1&pageSize=20";

  //For Categories name
  static const String foodCategories = "$baseurl_api/discovery/categories/food";

  // API to display items of a specific food category
  static String getFoodByCategory(String categoryId) =>
      "$baseurl_api/discovery/menu-items/category/$categoryId";

  // API to get specific menu item details by ID
  static String getMenuItemById(String itemId) =>
      "$baseurl_api/discovery/menu-items/$itemId";


  //For Delivery Man
  static const String deliveryMenStatus = "$baseurl_api/delivery-men/status";
  // API for delivery men to see their orders
  static const String deliveryMenOrders = "$baseurl_api/delivery-men/orders";

  // API to mark an order as picked up by the delivery man
  static String pickupOrder(String orderId) =>
      "$baseurl_api/delivery-men/orders/$orderId/pickup";

  // API to mark an order as successfully delivered by the delivery man
  static String deliverOrder(String orderId) =>
      "$baseurl_api/delivery-men/orders/$orderId/deliver";


}