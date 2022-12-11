# MerchantMagic
MerchantMagic is an addon for World of Warcraft, currently only for Mists of Pandaria (5.4.8). 

The addon lets you maintain a list of rules of items to always sell to a vendor. It is flexible, and has per-character rulesets.

# Installation
You install this like any other addon, by dropping the addon folder ("MerchantMagic") into ```WoW Install Path\Interface\AddOns```.

# Operation
The addon operates in the following way: Whenever you visit a merchant (vendor), MerchantMagic scans your bags and checks each and every item against your rulesets. If an item is found to match every single rule in a ruleset, it is sold, and processing moves on to the next item in your bags. If an item has no sell value, it is ignored.

# Terminology
* **Ruleset** - A ruleset is a set of rules. Every rule in a ruleset must be matched in order for an item to be matched against the whole set (boolean AND). Rules within a ruleset are separated by semi-colons. Example:
  * ```type=consumable;subtype=scroll```  - A ruleset matching all scrolls
* **Rule** - A rule is what the name implies, a rule that has to be matched by the item being checked. A rule has two parts, the parameter and the argument, separated by an equals sign ```=```. Optionally, the parameter can be a comma-separated list of all acceptable values (boolean OR). Examples:
	* ```type=armor``` - A rule matching pieces of armor
	* ```type=armor,weapon``` - A rule matching pieces of armor or weapons
* **Parameter** - A parameter is a variable that defines a property of the item to be matched against. It is the first part of a rule, i.e. it is the "type" in ```type=armor```. A parameter has to be one of the following:
	* "name", "rarity", "type", "subtype", "ilvl", "level", "sellprice", "bindtype"
* **Argument** - An argument is a value supplied to a parameter, i.e. it is the "armor" in ```type=armor```. An argument has to be appropriate for the parameter it is supplied to. You can see a table of valid arguments further down on this page. Arguments can be separated by a comma ```,``` in order to match more than one value to the parameter, i.e. ```type=weapon,armor``` will check if the item is a weapon OR a piece of armor. You can use as many comma-separated arguments as you wish.

# Operators
* Parameters that take strings (text) as their argument can only use the equals sign ```=``` operator.
* Parameters that take numbers as their argument can be used with the operators less-than ```<```, greater-than ```>``` or equals ```=```.

See the bottom of this readme for a table of accepted parameters, operators and arguments.

# Usage
Use **/mm \<command\>** (or /merchantmagic \<command\>) to access the addon in-game.

## Valid commands
### Addon settings
#### toggle

Turn MerchantMagic on/off

Example: ```/mm toggle``` - Turns the addon off if it's on, or on if it's off

#### verbose

Turn verbose mode on/off. Verbose mode will print more information about what the addon is doing

Example: ```/mm verbose``` - Turns verbose mode off if it's on, or on if it's off

**max12** 

Turn Max12 mode on/off. Max12 mode limits the number of items sold to a vendor to 12 on each visit. Use this if you are unsure that you've written your rulesets correctly, as with this enabled, you will able to buy back any items sold by mistake.

Example: ```/mm max12``` - Turns Max12 mode off if it's on, or on if it's off

**tooltip**

Turn MM tooltip info on/off. This option will show a line of text in item tooltips if the item matches any of your rulesets, or if they are in your whitelist. Non-matching items will not have any information added to their tooltip.

Example: ```/mm tooltip``` - Turns the MM tooltip off if it's on, or on if it's off

**tooltip verbose**

Toggle showing ruleset content in item tooltip info. This will add an additional line of text to the tooltip of matching items, and will show the full ruleset that it matched.

Example: ```/mm tooltip verbose``` - Turns the MM tooltip verbose mode off if it's on, or on if it's off

**tooltip info**

Toggle showing item info in MM tooltip. This will show information about each and every item you hover over, in the form of MerchantMagic rules. Use this to quickly find an item's type, sale value, etc. This is the same information supplied if you use the ```/mm info [item link]``` command manually.

Example: ```/mm tooltip info``` - Turns the MM tooltip item info off if it's on, or on if it's off

### Ruleset commands
**add \<ruleset\>**

Add a new ruleset

Example: ```/mm add type=armor;ilvl<300``` - Adds a new ruleset with rules matching armor that has an item level less than 300

**remove \<rulesetID\>**

Remove ruleset \<ruleID\>

Example: ```/mm remove 5``` - Removes ruleset number 5.

**edit \<rulesetID\> \<newRuleset\>**

Edit ruleset \<ruleID\>, replacing it with \<newRuleset\>

Example: ```/mm edit 3 type=weapon;rarity=1``` - Replaces ruleset number 3 with a new ruleset that matches weapons of white/common rarity.

**enable \<rulesetID\>**

Enable ruleset \<rulesetID\>

Example: ```/mm enable 7``` - Enables ruleset number 7.

**disable \<rulesetID\>**

Disable ruleset \<rulesetID\>

Example: ```/mm disable 9``` - Disables ruleset number 9.

**move \<fromID\> \<toID\>**

Move ruleset from \<fromID> to \<toID>, pushing \<toID\> and subsequent rules down one level.

Example: ```/mm move 10 3``` - Moves ruleset number 10 to number 3, pushing the ruleset that previously had number 3 down to number 4, then 4 to 5, and so on.

**swap \<fromID\> \<toID\>**

Swap \<fromID\> \<toID\> ruleset positions

Example: ```/mm swap 7 9``` - Swaps the positions of rulesets number 7 and 9.

**test \<itemLink\>**

Test \<itemLink\> against current rulesets

Example: ```/mm test [Windwool Cloth]``` - Runs the item link [Windwool Cloth] through your rulesets to see if it matches any of them, and outputs the information to your chat frame.

**testbags**

Test contents of bags against current rulesets (dry run)

Example: ```/mm testbags``` - Tests all the items in your bags against your active rulesets and pretends to sell them. This is essentially a dry run of actually visiting a vendor, and will show you all the same information, without actually vendoring any items.

**info \<itemLink\>**

Show relevant info about \<itemLink\>

Example: ```/mm info [Roasted Barley Tea]``` - Prints out all info relevant to MerchantMagic about the item link [Roasted Barley Tea]. This is the same info that is shown in the tooltip if you enable tooltip item info mode.

**clear**

Clear all rulesets

Example: ```/mm clear``` - Attempts to delete all your rulesets. MerchantMagic will ask you to issue the same command again in order to confirm, as this cannot be undone.

**rulesethelp**

Show in-game help on how to write a ruleset

Example: ```/mm rulesethelp``` - Prints out information on how to write a ruleset to your chat frame

### Whitelist commands
Whitelisted items will never be vendored. 
*Note that the whitelist does not take rulesets as arguments, only item names!*

**whitelist**

Show whitelist commands

Example: ```/mm whitelist``` - Prints out information on how to use the whitelist to your chat frame

**whitelist add \<item name or link\>**

Add an item to the whitelist. You can supply just the name of an item, or an item link that the name will be extracted out of. 

Example: ```/mm whitelist add sharpened tuskarr spear``` - Adds the item [Sharpened Tuskarr Spear] to your whitelist. 

**whitelist remove \<item name or link\>**

Remove specified item from whitelist

Example: ```/mm whitelist remove sharpened tuskarr spear``` - Removes the item [Sharpened Tuskarr Spear] from your whitelist. 

**whitelist list**

List all items currently in the whitelist

Example: ```/mm whitelist list``` - Prints the contents of your whitelist to the chat frame

**whitelist clear**

Clear the whitelist of all item names

Example: ```/mm whitelist clear``` - Empties your whitelist of all items. MerchantMagic will ask for confirmation before doing this, as it cannot be undone.

# Table of accepted parameters, operators and arguments
Remember that you can easily find the arguments you need to match an item by doing ```/mm info [item link]```, or enabling tooltip info mode with ```/mm tooltip info```.

| Parameter | Accepted operators | Accepted arguments |
| ---- | ---- | ---- | ---- |
| name | = | Absolute name of an item, e.g. "hozen cuervo"|
| rarity | < > = | A number from 0 to 4, indicating item rarity/quality:<br />0 = Poor/Gray<br />1 = Common/White<br />2 = Uncommon/Green<br />3 = Rare/Blue<br />4 = Epic/Purple|
| type | = | One of the following types: "armor", "consumable", "container", "gem", "key", "miscellaneous", "money", "reagent", "recipe", "projectile", "quest", "quiver", "trade goods", "weapon" |
| subtype | = | One of the following subtypes: "miscellaneous", "cloth", "leather", "mail", "plate", "shields", "librams", "idols", "totems", "sigils", "food & drink", "potion", "elixir", "flask", "bandage", "item enhancement", "scroll", "other", "consumable", "bag", "enchanting bag", "engineering bag", "gem bag", "herb bag", "mining bag", "soul bag", "leatherworking bag", "blue", "green", "orange", "meta", "prismatic", "purple", "red", "simple", "yellow", "key", "junk", "reagent", "pet", "holiday", "mount", "other", "reagent" , "alchemy", "blacksmithing", "book", "cooking", "enchanting", "engineering", "first aid", "leatherworking", "tailoring", "arrow", "bullet", "quest", "ammo pouch", "quiver", "cloth", "devices", "elemental", "enchanting", "explosives", "herb", "item enchantment", "jewelcrafting", "leather", "materials", "meat", "metal & stone", "other", "parts", "trade goods", "bows", "crossbows", "daggers", "guns", "fishing poles", "fist weapons", "miscellaneous", "one-handed axes", "one-handed maces", "one-handed swords", "polearms", "staves", "thrown", "two-handed axes", "two-handed maces", "two-handed swords", "wands", "alcohol" |
| ilvl | < > = | A number representing an item level, e.g. ```ilvl<400```, matching items with item level less than 400. |
| level | < > = | A number representing the required level for an item, e.g. ```level=85```, matching items with required level exactly 85. |
| sellprice | < > = | A number representing the sale price for an item, expressed in copper, e.g. ```sellprice>100000```, matching items that has a sell price greater than 10 gold. |
| bindtype | = | |