# RaidReserve

A World of Warcraft addon for Mists of Pandaria Classic that helps raid leaders manage item reservations through whispers.

## Features

- Simple whisper-based item reservation system
- Real-time tracking of item reservations
- Automatic raid announcements
- Item level validation for MoP content
- Session persistence between reloads
- CSV export functionality
- Clean and intuitive UI

## Installation

1. Download the latest release
2. Extract the contents to your `World of Warcraft/Interface/AddOns` directory
3. The folder structure should look like: `Interface/AddOns/RaidReserve/`
4. Restart World of Warcraft if it's running

## Usage

### Raid Leader Commands

- `/res start` - Start a new reservation session
- `/res stop` - End the current session and display summary
- `/res clear` - Clear all current reservations
- `/res show` - Toggle the reservation window
- `/res announce` - Manually announce to raid/party

### For Raiders

1. Wait for the raid leader to start a reservation session
2. When prompted, whisper the raid leader with item links you want to reserve
3. You'll receive confirmation when your reservation is accepted

## Features

### Item Validation

- Only items from MoP content (item level 372-516) can be reserved
- Duplicate reservations are prevented
- Only raid/party members can make reservations

### Session Management

- Sessions persist through game reloads
- Automatic announcements with cooldown
- Complete reservation history

### Export

- Export all reservations in CSV format
- Compatible with spreadsheet software
- Includes player names, items, and timestamps

## Support

For issues or suggestions, please create an issue in the GitHub repository.

## License

This addon is released under the MIT License. See the LICENSE file for details.