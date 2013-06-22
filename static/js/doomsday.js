function EventRow(json) {
  var self = this;
  self.date = json.date;
  self.description = json.description;
  self.eventid = json.eventid;
}

function EventModel() {
  var self = this;
  self.events = ko.observableArray([]);
  self.update = function() {
    $.getJSON("/events", function(data) {
      self.events.removeAll();
      _.each(_.pairs(data), function(p) {
        var eventData = {
          eventid: p[0],
          description: p[1].event,
          date: p[1].day
        };
        self.events.push(new EventRow(eventData));
      });
    });
  };
  self.update(); 
}

$(function() {
  var model = new EventModel();
  ko.applyBindings(model);  

  $("#add-date").datepicker();
  $("#add-btn").click(function() {
    var req = {date: $("#add-date").val(), description: $("#add-desc").val()};
    console.log("Posting: ", req);
    $.post("/add", JSON.stringify(req), function() {
      $("#add-form input").val("");
      model.update();
    });
  });
  $(".delete-event").click(function() {
    var eventid = $(this).data('eventid');
    // submit del req for $eventid
  });
});

