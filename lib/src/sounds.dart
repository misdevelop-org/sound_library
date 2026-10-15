/// Groups of sounds that serve the same purpose in an app.
enum SoundCategory {
  /// Taps, clicks, drags and other direct responses to the user's touch.
  interaction('Interaction', 'Taps, clicks, drags and pops: the direct response to a touch.', 'interaction'),

  /// Opening and closing screens, panels, menus and drawers.
  navigation('Navigation', 'Opening and closing pages, panels, menus and drawers.', 'navigation'),

  /// Outcomes of an action: success, deletion and alerts.
  feedback('Feedback', 'The outcome of an action: success, deletion and alerts.', 'feedback'),

  /// Alerts that reach the user even when they are not looking at the screen.
  notification('Notification', 'Alerts, mentions, reminders and alarms.', 'notification'),

  /// Messages, chats and typing.
  communication('Communication', 'Sending, receiving and typing messages.', 'communication'),

  /// Shopping, orders and payments.
  commerce('Commerce', 'Carts, orders and payments.', 'commerce'),

  /// Intros and welcomes that give an app its personality.
  brand('Brand', 'Intros and welcomes that give your app its personality.', 'brand');

  const SoundCategory(this.label, this.description, this.folder);

  /// Human readable name.
  final String label;

  /// What the sounds in this category are meant for.
  final String description;

  /// Folder inside `assets/sounds/` that holds the files of this category.
  final String folder;

  /// The sounds that belong to this category.
  List<Sounds> get sounds => Sounds.values.where((sound) => sound.category == this).toList(growable: false);
}

/// Every sound bundled with the package. Play them with `SoundPlayer.play`.
enum Sounds {
  // Interaction
  /// General button click. Very short.
  click(SoundCategory.interaction, 'click.mp3', 'Click', 'General button click.'),

  /// Soft, almost silent tap. Good for dense UIs where a click would be too much.
  tap(SoundCategory.interaction, 'tap.wav', 'Tap', 'Soft tap for dense UIs and frequent taps.'),

  /// Short beep.
  bip(SoundCategory.interaction, 'bip.mp3', 'Bip', 'Short beep, for example when scanning a code.'),

  /// Drag and drop.
  drag(SoundCategory.interaction, 'drag.mp3', 'Drag', 'Drag and drop.'),

  /// Something pops into view.
  popIn(SoundCategory.interaction, 'pop_in.wav', 'Pop in', 'A tooltip, chip or bubble appears.'),

  /// Something pops out of view.
  popOut(SoundCategory.interaction, 'pop_out.wav', 'Pop out', 'A tooltip, chip or bubble disappears.'),

  /// General action, usually without direct user interaction.
  action(SoundCategory.interaction, 'action.mp3', 'Action', 'General action, usually without user interaction.'),

  /// A switch turns on.
  toggleOn(SoundCategory.interaction, 'toggle_on.wav', 'Toggle on', 'A switch or checkbox turns on.'),

  /// A switch turns off.
  toggleOff(SoundCategory.interaction, 'toggle_off.wav', 'Toggle off', 'A switch or checkbox turns off.'),

  /// A picker, tab or list item is selected.
  select(SoundCategory.interaction, 'select.wav', 'Select', 'Pick an item in a list, a tab or a picker.'),

  // Navigation
  /// Open a drawer, menu or popup.
  open(SoundCategory.navigation, 'open.mp3', 'Open', 'Open a drawer, menu or popup.'),

  /// Close a drawer, menu or popup. Two wood blocks.
  woodHit(
      SoundCategory.navigation, 'wood_hit.mp3', 'Close (wood hit)', 'High pitched hit of two wood blocks to close.'),

  /// Navigate forward to a page.
  openPage(SoundCategory.navigation, 'open_page.wav', 'Open page', 'Navigate forward to a page.'),

  /// Navigate back from a page.
  closePage(SoundCategory.navigation, 'close_page.wav', 'Close page', 'Navigate back from a page.'),

  /// Slide a side panel in.
  openPanel(SoundCategory.navigation, 'open_panel.wav', 'Open panel', 'Slide a side panel or sheet in.'),

  /// Slide a side panel out.
  closePanel(SoundCategory.navigation, 'close_panel.wav', 'Close panel', 'Slide a side panel or sheet out.'),

  // Feedback
  /// Something succeeded or completed.
  success(SoundCategory.feedback, 'success.mp3', 'Success', 'Something succeeded or completed.'),

  /// An item or file was deleted.
  deleted(SoundCategory.feedback, 'deleted.mp3', 'Deleted', 'Delete an item or a file.'),

  /// A lighter delete.
  remove(SoundCategory.feedback, 'remove.wav', 'Remove', 'A lighter delete, for removing a row or a chip.'),

  /// Long glass chime.
  glass(SoundCategory.feedback, 'glass.mp3', 'Glass', 'Long glass chime for notices worth noticing.'),

  /// Something went wrong.
  error(SoundCategory.feedback, 'error.mp3', 'Error', 'Something went wrong. Two falling, buzzy notes.'),

  /// Heads up.
  warning(SoundCategory.feedback, 'warning.mp3', 'Warning', 'Heads up: a double beep.'),

  /// Neutral information.
  info(SoundCategory.feedback, 'info.mp3', 'Info', 'A soft bell for neutral information.'),

  // Notification
  /// A new notification.
  notification(SoundCategory.notification, 'notification.mp3', 'Notification', 'A new notification. Two rising bells.'),

  /// Someone mentioned the user.
  mention(SoundCategory.notification, 'mention.mp3', 'Mention', 'Someone mentioned you. A quick rising arpeggio.'),

  /// A reminder is due.
  reminder(SoundCategory.notification, 'reminder.mp3', 'Reminder', 'A reminder is due. Two bells with an echo.'),

  /// An alarm.
  alarm(SoundCategory.notification, 'alarm.mp3', 'Alarm', 'An alarm or timer going off. Alternating beeps.'),

  // Communication
  /// A message was sent.
  messageSent(
      SoundCategory.communication, 'message_sent.wav', 'Message sent', 'A message was sent. A quick upward swoosh.'),

  /// A message arrived.
  messageReceived(
    SoundCategory.communication,
    'message_received.mp3',
    'Message received',
    'A message arrived. Two soft rising notes.',
  ),

  /// A typewriter key strike.
  typing(SoundCategory.communication, 'typing.wav', 'Typing',
      'A typewriter key strike, for typing indicators and keyboards.'),

  // Commerce
  /// A payment went through.
  paymentSuccess(
      SoundCategory.commerce, 'payment_success.mp3', 'Payment success', 'A payment went through. A rising arpeggio.'),

  /// A payment was declined.
  paymentFailed(
      SoundCategory.commerce, 'payment_failed.mp3', 'Payment failed', 'A payment was declined. Two falling notes.'),

  /// A coin.
  coin(SoundCategory.commerce, 'coin.mp3', 'Coin', 'A coin drops: a bright two-note blip.'),

  /// Item added to the cart.
  addToCart(SoundCategory.commerce, 'add_to_cart.mp3', 'Add to cart', 'Item added to the cart.'),

  /// Order completed.
  orderComplete(SoundCategory.commerce, 'order_complete.mp3', 'Order complete', 'An order was completed.'),

  /// Cash register.
  cashingMachine(SoundCategory.commerce, 'cashing_machine.mp3', 'Cashing machine', 'Cash register ka-ching.'),

  // Brand
  /// Full intro jingle.
  intro(SoundCategory.brand, 'intro.mp3', 'Intro', 'Full intro jingle, about 6 seconds.'),

  /// Short intro jingle.
  introShort(SoundCategory.brand, 'intro_short.wav', 'Intro (short)', 'Short intro jingle, about 4 seconds.'),

  /// Welcome sound.
  welcome(SoundCategory.brand, 'welcome.mp3', 'Welcome', 'Welcome sound.');

  const Sounds(this.category, this.file, this.label, this.description);

  /// The category this sound belongs to.
  final SoundCategory category;

  /// File name inside the category folder, including its extension.
  final String file;

  /// Human readable name.
  final String label;

  /// What the sound is meant for.
  final String description;

  /// Asset key of the file, as expected by `AssetBundle` and `AssetSource`.
  String get assetPath => 'packages/sound_library/assets/sounds/${category.folder}/$file';

  /// All sounds grouped by category, in declaration order.
  static Map<SoundCategory, List<Sounds>> get byCategory => {
        for (final category in SoundCategory.values) category: category.sounds,
      };
}
