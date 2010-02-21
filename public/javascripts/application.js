// Common JavaScript code across your application goes here.

function refresh_trips() {
  jQuery.get("/trips.js",{from: $('#from').attr("value"), to: $('#to').attr("value")}, function(data) {
    if ($("table#trips").length > 0) {
      x = $("<tbody></tbody>");
      cls = "odd";
      jQuery.each(data, function() {
	cls = cls == "even" ? "odd" : "even";
	x.append("<tr class='" + cls + "'><td colspan=\"5\">" + this.from + "</td><td>" );
      });
      $($("table#trips")[0]).find("tbody").remove();
      $($("table#trips")[0]).append(x);
    }
  }, "json");
}

$(document).ready(function() {
  $("#from").autocomplete(data, {
    formatResult: function(row){return (row + "").split(",")[1];return false;},
    autofill: false,
    matchContains: true
  });
  $("#from").result(function(event, d, formatted) {
    if(d){
      $("#trip_start_stop_id").attr("value",((d+"").split(",")[0]));
      refresh_trips();
      return false;
    }
  });
  $("#to").autocomplete(data, {
    formatResult: function(row){return (row + "").split(",")[1];return false;},
    autofill: false,
    matchContains: true
  });
  $("#to").result(function(event, d, formatted) {
    if(d){
      $("#trip_end_stop_id").attr("value",((d+"").split(",")[0]));
      refresh_trips();
      return false;
    }
  });
});

