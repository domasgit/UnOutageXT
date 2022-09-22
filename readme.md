1. Extract downloaded backup file
2. Open the extracted folder and extract db.sqlite.bz2 to get db.sqlite
3. Drag and drop the db.sqlite file into folder where you have extracted_to_0.command
4. Go to FP enterprise portal and export Transaction list for the period after outage in csv
5. Rename it to foobar.csv and drop it into script folder
6. Run extracted_to_0.commamnd

   **NOTE**: at this point you might get error that file comes from untrusted developer - if you do navigate to Settings-> Security&Privacy -> you will see a line informing you that extracted_to_0.command was blocked - press open anyway.
   The script will run by doubletapping it from there on
   If it's still asking for permissions on the next time you run it do this instead:

* In the Finder  on your Mac, locate the app you want to open.
   Don’t use Launchpad to do this. Launchpad doesn’t allow you to access the shortcut menu.
* Control-click the app icon, then choose Open from the shortcut menu.
* Click Open.

The app is saved as an exception to your security settings, and you can open it in the future by double-clicking it just as you can any registered app.

7. Script will run and adjust the db, you'll find the db renamed to pos2v.sqlite
8. Drag drop pos2v.sqlite to your com.re.pos folder and run the emulator - the payments will appear in offline payments screen from where you can then retry them