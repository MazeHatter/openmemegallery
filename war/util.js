if (typeof omg == "undefined")
	omg = {};

if (!omg.util)
	omg.util = {};

omg.util.getTimeCaption = function (timeMS) {

	var plural;
	
    var seconds = Math.round((Date.now() - timeMS) / 1000);
    if (seconds < 60) {
    	plural = seconds == 1 ? "" : "s";
        return seconds + " sec" + plural + " ago";
    }

    var minutes = Math.floor(seconds / 60);
    if (minutes < 60) {
    	plural = minutes == 1 ? "" : "s";
        return minutes + " min" + plural + " ago";    
    }

    var hours = Math.floor(minutes / 60);
    if (hours < 24) {
    	plural = hours == 1 ? "" : "s";
        return hours + " hr" + plural + " ago";    
    }

    var days = Math.floor(hours / 24);
    if (days < 7) {
    	plural = days == 1 ? "" : "s";
        return days + " day" + plural + " ago";    
    }

    var date  = new Date(timeMS);
    
    var monthday = omg.util.getMonthCaption(date.getMonth()) + " " + date.getDate();
    if (days < 365) {
    	return monthday;
    }
    return monthday + " " + date.getYear();

};

omg.util.getMonthCaption = function (month) {
    if (!omg.util.months) {
        omg.util.months = ["Jan", "Feb", "Mar", "Apr", "May",
                      "Jun", "Jul", "Aug", "Sep", "Oct", 
                      "Nov", "Dec"];
    }
    return omg.util.months[month];
};
