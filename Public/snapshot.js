#import "SnapshotHelper.js"

var target = UIATarget.localTarget();
var app = target.frontMostApp();
var window = app.mainWindow();

target.delay(5);
captureLocalizedScreenshot("0-EmptyState");

window.searchBars()[0].setValue("ゴジラ");
app.keyboard().buttons()["Search"].tap();
captureLocalizedScreenshot("1-Godzilla");

window.searchBars()[0].setValue("Lord of the Rings: The Return of the King");
window.tableViews()[0].cells()[0].tap();
captureLocalizedScreenshot("2-LOTR");
app.navigationBar().leftButton().tap();

window.searchBars()[0].tap();
window.searchBars()[0].setValue("螢火蟲");
captureLocalizedScreenshot("3-Fireflies");

window.searchBars()[0].setValue("So was");
window.tableViews()[0].cells()[0].tap();
captureLocalizedScreenshot("4-ALotLikeLove");
app.navigationBar().leftButton().tap();
