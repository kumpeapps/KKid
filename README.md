# KKid

[![Codacy Badge](https://api.codacy.com/project/badge/Grade/3fc8d8e6579d4620a526d5fd4d9f1a0f)](https://app.codacy.com/gh/kumpeapps/KKid?utm_source=github.com&utm_medium=referral&utm_content=kumpeapps/KKid&utm_campaign=Badge_Grade)

<img src="https://img.shields.io/badge/platform-iOS%2015.0%2B-lightgrey"/> <img src="https://img.shields.io/github/v/release/kumpeapps/kkid?color=%233D9970"/> <img src="https://img.shields.io/badge/swift-5-green"/> <img src="https://img.shields.io/uptimerobot/status/m778927661-24953be87bd254731f918d97?label=server%20status"/> <img src="https://img.shields.io/uptimerobot/ratio/m778927661-24953be87bd254731f918d97?label=server%20uptime"/> <img src="https://img.shields.io/github/last-commit/kumpeapps/kkid"/> ![Codacy Security Scan](https://github.com/kumpeapps/KKid/workflows/Codacy%20Security%20Scan/badge.svg) ![SL Scan](https://github.com/kumpeapps/KKid/workflows/SL%20Scan/badge.svg) ![iTunes App Store](https://img.shields.io/itunes/v/1533368166?label=apple%20app%20store&style=plastic)

<a href="https://apps.apple.com/us/app/kkid/id1533368166?itsct=apps_box&amp;itscg=30200" style="display: inline-block; overflow: hidden; border-top-left-radius: 13px; border-top-right-radius: 13px; border-bottom-right-radius: 13px; border-bottom-left-radius: 13px; width: 250px; height: 83px;"><img src="https://tools.applemediaservices.com/api/badges/download-on-the-app-store/black/en-US?size=250x83&amp;releaseDate=1602028800&h=79ad7188cd7d3f71708c7d97d39c5fa3" alt="Download on the App Store" style="border-top-left-radius: 13px; border-top-right-radius: 13px; border-bottom-right-radius: 13px; border-bottom-left-radius: 13px; width: 250px; height: 83px;"></a>

KKid is an app for parents and their children to keep up with chores and allowance. With this app parents can create child accounts and add chores to their profile. Kids can then login and see their chores and mark them off each day. By turning on the allowance feature parents can add/subtract money from the kid's allowance account (this is a virtual "account" to show the kids how much allowance they have, no money is actually exchanged within the KKid app, think of it as a notebook) and the kids can view this when they login as well.

## Support
-   For Support please [create new issue](https://github.com/kumpeapps/KKid/issues)

## Screenshots
| Home | Select User | Login | Allowance | Chores | Search Movies | Movie Details |
| :-----------------: | :-----------------: | :-----------------: | :-----------------: | :-----------------: | :-----------------: | :-----------------: |
| ![home.png](fastlane/screenshots/en-US/iPhone%2011%20Pro%20Max-HomeScreen_framed.png)  | ![selectUser.png](fastlane/screenshots/en-US/iPhone%2011%20Pro%20Max-SelectUserScreen_framed.png)  | ![login.png](fastlane/screenshots/en-US/iPhone%2011%20Pro%20Max-LoginScreen_framed.png)    | ![allowance.png](fastlane/screenshots/en-US/iPhone%2011%20Pro%20Max-AllowanceScreen_framed.png)	| ![chores.png](fastlane/screenshots/en-US/iPhone%2011%20Pro%20Max-ChoresScreen_framed.png)	| ![searchmovies.png](fastlane/screenshots/en-US/iPhone%2011%20Pro%20Max-SearchMovies_framed.png)	| ![chores.png](fastlane/screenshots/en-US/iPhone%2011%20Pro%20Max-MovieDetails_framed.png)	|

## Frameworks Used
-   Foundation
-   UIKit
-   CoreData
-   CoreText

## Third Party Frameworks Used
-   [Alamofire-SwiftyJSON](https://github.com/SwiftyJSON/Alamofire-SwiftyJSON)
-   [Toast-Swift](https://github.com/scalessec/Toast-Swift)
-   [SwiftyForm](https://github.com/neoneye/SwiftyFORM)
-   [ReachabilitySwift](https://github.com/ashleymills/Reachability.swift)
-   [SwiftMessages](https://github.com/SwiftKickMobile/SwiftMessages)
-   [Sync](https://github.com/3lvis/Sync)
-   [Smile](https://github.com/onmyway133/Smile)
-   [CollectionViewCenteredFlowLayout](https://github.com/Coeur/CollectionViewCenteredFlowLayout)
-   [Haptico](https://github.com/iSapozhnik/Haptico)
-   [PrivacyKit](https://github.com/ithazfire/PrivacyKit)
-   [BadgeSwift](https://github.com/evgenyneu/swift-badge)
-   [TransitionButton](https://github.com/AladinWay/TransitionButton)
-   [Kingfisher](https://github.com/onevcat/Kingfisher)
-   [JKRefresher](https://github.com/kumpeapps/JKRefresher)
-   [YoutubeKit](https://github.com/rinov/YoutubeKit)
-   [ContentRestrictionsKit](https://github.com/kumpeapps/ContentRestrictionsKit)
-   [ShipBook](https://github.com/ShipBook/ShipBookSDK-iOS)
-   [WhatsNew](https://github.com/BalestraPatrick/WhatsNew)
-   [PBTutorialManager](https://github.com/paul1893/PBTutorialManager)
-   [Unsplash](https://github.com/unsplash/unsplash-photopicker-ios#unsplash-photo-picker-for-ios)

## Other Credits
-   [Icons from Icons8](https://icons8.com)
-   [TMDb](https://themoviedb.org)
-   [Gravatar](https://www.gravatar.com)
-   [custom backgrounds provided by Unsplash](https://www.unsplash.com)

## Instructions

### Login Screen
-   On the login screen you can enter your username/email and password then click login to access the application.
-   If you need to create a new Master Parent (household) account you may click on "New Parent Account"
-   If you have forgotten your password you may enter your username in the username field and click "Forgot Password" and a reset link will be emailed to you.
-   After login you will be taken to the [Home](https://github.com/kumpeapps/KKid#select-module-screen-home-screen) Screen

###### NOTE: Child accounts and additional parent accounts for an existing household must be created after logging in as the master user or an admin user

-   DEMO Account
	-   username: dev_kkid_master
	-   password: LetmeN2it

### Select Module Screen (Home Screen)
-   The "Select Module" Screen will be diffrent for each user.
-   You will always have Edit Profile which you can click on to edit that user's profile/permissions
-   Additionally there will be options for each module that the selected user has access to
-   Click on Edit Profile to edit the  user's profile or click on the module name to access that module for the user
-   Current Module options are: [Edit Profile](https://github.com/justinkumpe/KKid#edit-profile-module), [Chores](https://github.com/justinkumpe/KKid#chores-module), [Allowance](https://github.com/justinkumpe/KKid#allowance-module), [Movies DB](https://github.com/justinkumpe/KKid#movies-db-module), and [Wish List](https://github.com/justinkumpe/KKid#wish-list-module)

### Select User Screen (Click on your avatar in upper right for Select User Screen)
-   On the Select User screen you will see a list of users under your master (household) account.
-   If you are the master user (purple ring) or an admin user (yellow ring) then you may add an additional user/kid/parent/admin by clicking the plus symbol in the upper right corner of the screen
-   If you are the master user or an admin user tap and hold until icons wiggle then tap on user to delete the user. (NOTE: The master user can only be deleted once all other users have been deleted from the master account

|      User Type          |      Ring Color     |
|   :-----------------:   | :-----------------: |
|   Master/Main Account   |        Purple       |
|     Parent/Admin        |        Yellow       |
|        Child            |         Teal        |
|     Locked/Disabled     |          Red        |

#### Add User Screen
-   Enter the new user's username, email, password, first name, and last name. Then click submit
-   NOTE: each user must have their own email address. We understand that some kids do not have their own email account. In this case you can use an email alias that is automatically build into all email accounts. To do this you just add + then the alias directly before the @ symbol of your email address. Example: if your email address is jane@doe.com and you need an email alias for jack then you can use jane+jack@doe.com. Any email sent to jane+jack@doe.com will be automatically forwarded to jane@doe.com

#### Edit Profile Module
-   To edit a the user's profile just change the information on the screen and click update in the upper right.
-   If you are the master or an admin user then you will have switches for each module/permission. To turn on the permission for a user just change the switch to on. To remove a permission from the user then you turn the switch to off. Do not forget to click update in the upper right to update the users permissions as well.
-   In the Push Notifications section you can customize which push notifications the user receives for modules the user has access too.
-   In the link accounts section you can link/re-link third-party accounts used by KKid.
-   To change your Avatar Photo you will need to create an account with [Gravatar](https://www.gravatar.com) using the same email you used for KKid. KKid will then sync your new avatar within 24hrs.
-   Click on "Set Custom Background" to set your background to an image from Unsplash.com

#### Chores Module
-   In this module you will see a table listing the selected user's chores for the week.
-   To the left of the chore will be an icon indicating the status of that chore
-   To mark off (change status of) a chore just select the chore and the [Mark Chore](https://github.com/justinkumpe/KKid#mark-chore-screen) screen will appear.
-   If you are the master or an admin user then you may add a chore to the selected user by clicking the add button in the upper right corner of the screen to goto the [Add Chore](https://github.com/justinkumpe/KKid#add-chore-screen) screen.
-   If you are the master or an admin user then you may delete a chore by swiping the chore to the left

##### Mark Chore Screen
-   On this screen you will see the options for marking the selected chore.
-   Possible options on this screen are a green check (chore is completed), a blue dash (chore does not need to be completed), and a red x (chore was not done)
-   Click on one of the markings (check,dash,x) to change the status of the chore.
-   Note: some chores can be restricted by the parent to block the dash button which may cause this button to not be available. Also if a chore is marked as an X then the X is the only option available unless you are the master or admin user.

##### Add Chore Screen
-   To add a chore to the selected user fill out the form and click submit in the upper right corner.
-   If block dash is turned on then the user will not be able to mark this chore as a dash (chore does not need to be done today)
-   If optional is turned on then this chore will be notated as optional on the chore list
-   If Any Kid is turned on then this chore will show up on all users under your master/household account that have the chore module turned on
-   Start Date is the date you wish this chore to start (Example: if today is Friday and you want to add a chore for next week then you may want to change the start date to next week)
-   If One Time Chore is selected then this chore will be on this week's chore list only and will be deleted at the end of the week. By default chores are carried over to the following week.

###### NOTE: the weeks start on Sunday (Central Standard Time Zone)

#### Allowance Module
-   This screen will display the user's current allowance balance
-   Clicking the ledger icon (open book) in the upper right will launch the Ledger screen which will show all of the allowance transactions for this user
-   Clicking the + icon in the upper right will launch the [Add Transaction](https://github.com/justinkumpe/KKid#add-transaction-screen) Screen

###### NOTE: The Allowance Module is for parents/kids to keep up with how much allowance they have so parents can give them a virtual allowance account instead of the kid keeping up with cash. The parent is the "Bank". No money is exchanged directly thru this app. It is only to keep track of how much allowance the parent "owes" the kid

##### Add Transaction Screen
-   On this screen you can add transactions (add/subtract) for the selected user's allowance. Just fill out the form and click submit
-   Master and Admin users may add or subtract allowance
-   Users that are not a master or admin may only subtract from their allowance account

### Movies DB Module
-   This module will allow you to search movies and add them to a favorites or watch list. By clicking on the movie you can pull up the [Movie Details Screen](https://github.com/justinkumpe/KKid#movie-details-screen).
-   The tabs at the top will switch you between search, favorites, and watch list
-   TMDb account is required to utilize the favorites and watch list features and your TMDb account must be linked to your KKid account via [Edit Profile](https://github.com/justinkumpe/KKid#edit-profile-module)

###### NOTE: If movie ratings limits/restrictions are configured on the device then KKid will remove any movies outside the allowed ratings from the search results. This will also remove any unrated movies from the search results
###### NOTE: It is recommended that you enable movie rating limits on your child's device before enabling this module

#### Movie Details Screen
-   This screen will show you details for the selected movie including Release date, overview, and rating
-   If available this screen will also play a trailer of the selected movie.
-   To replay the trailer you can click on the backdrop image.
-   Playing of movie trailers honors content restrictions on the device. Example: if a device is restricted to PG movies then the movies detail screen will not play movie trailers for movies rated above PG. NOTE: This restriction uses the movie rating as provided by TMDb. If a movie is not rated or there is no rating on file with TMDb then the trailer will not be restricted unless the rating restriction is set to Do Not Allow Movies.

### Wish List Module
-   This screen shows a list of items on the kid's wish list.
-   Items may be added to the wish list by clicking the add (+) button in the upper right.
-   If a URL link is provided when adding the item to the list then that item will show a link icon in the list and when you tap on that item it will take you to the link to ensure there is no confusion as to what item the person wants.
-   The share icon in the upper right will allow you to share a link to your wish list with other people. The link is a web link so other users without KKid access may still view your list (like grandparents/friends/family).

### REST API
REST API documentation is available at [https://restapi.kumpeapps.com/v5/ui/#/KKid](https://restapi.kumpeapps.com/v5/ui/#/KKid)
API access may be obtained by opening a support ticket

### Managed App Config
#### This app is compatible with managed app config settings pushed from an MDM Server. The following is a list of managed app keys for KKid

|         Key             |         Type        |             Description                |
|   :-----------------:   | :-----------------: |          :-----------------:           |
| disableNewParentAccount | Bool                | Disables the New Parent Account button |
| disableResetPassword    | Bool                | Disables the Forgot Password button    |
| username                | String	            | Pre-Populates the username field       |
| lockUsername            | Bool                | Disables editing the username field    |
| password                | String              | Pre-Populates the password field       |

## Future Feature List

-   [X] Add managed app config parameters
-   [X] What's New Page
-   [X] Gift wish list for the kids
-   [X] Movie Search with movie ratings
-   [X] TV Show Search with Ratings
-   [X] Linking TMDb account for saving movies/tv shows to favorites and watch list
-   [X] Share wish list with other people
