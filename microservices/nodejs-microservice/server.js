var express = require('express');
var app = express();

// Parse URL-encoded bodies (as sent by HTML forms)
app.use(express.urlencoded());

// Parse JSON bodies (as sent by API clients)
app.use(express.json());

// Access the parse results as request.body
app.post('/convert', function(request, response){
	response.send(convert(request.body.conversionText));
});

function convert(conversionText) {
    var convertedText = conversionText.replace("Oracle", "Oracle\u00A9");
    convertedText = convertedText.replace("Google", "Google\u00A9");
    convertedText = convertedText.replace("Microsoft", "Microsoft\u00A9");
    convertedText = convertedText.replace("Amazon", "Amazon\u00A9");
    convertedText = convertedText.replace("Deloitte", "Deloitte\u00A9");
    return convertedText;
}

var server = app.listen(4000, function () {
   var host = server.address().address
   var port = server.address().port
   
   console.log("App listening at http://%s:%s", host, port)
})