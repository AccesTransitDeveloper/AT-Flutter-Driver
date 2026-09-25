/// Constants related to socket communication.
class SocketConstants {
  // Keys for event name and data
  static const String keyEvent = 'event';
  static const String keyData = 'data';

  // Authorization header key
  static const String authorization = 'authorization';

  // Socket event names
  static const String eventSignUp = 'SIGN_UP';
  static const String bookingStatus = 'BOOKING_STATUS';
  static const String paymentStatus = 'PAYMENT_STATUS';
  static const String driverLiveLocation = 'DRIVER_LIVE_LOCATION';
  static const String eventJoinChat = 'JOIN_CHAT';
  static const String eventChatMessage = 'CHAT_MESSAGE';
  static const String eventChatMessagesFetch = 'CHAT_MESSAGES_FETCH';
  static const String eventChatMessageRead = 'CHAT_MESSAGE_READ';
  static const String eventDismissWebview = 'DISMISS_WEBVIEW';
  static const String eventUpdateCredit = 'UPDATE_CREDIT';
  static const String eventSubscriptionStatus = 'SUBSCRIPTION_STATUS';
  static const String eventDropVehicle = 'DROP_VEHICLE';
  static const String eventDriverZoneQueueNumber = 'DRIVER_ZONE_QUEUE_NUMBER';
  static const String eventDriverAutoOffline = 'DRIVER_AUTO_OFFLINE';
  static const String eventGetNewBooking = 'GET_NEW_BOOKING';
}
