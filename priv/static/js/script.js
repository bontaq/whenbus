$(document).ready(function(){
  var typingTimer,
      doneTypingInterval = 800,
      hourOffset = 0,
      busName = "";

  $('#search').keyup(function(){
    clearTimeout(typingTimer);
    if ($('#search').val()) {
      typingTimer = setTimeout(search, doneTypingInterval);
    }
  });

  function search() {
    var searchTerm = $('#search').val();

    if (searchTerm.length > 3) {
      $.ajax({
        url: "/api/find",
        type: "GET",
        dataType: "json",
        data: {
          "name": searchTerm
        },
        success: function( result ) {
          $('#stops .stop-name').each(function ( i ){
            $(this).fadeOut('fast', function() {
              $(this).remove();
            });
          });
          for (x in result) {
            $('#stops').append(
              '<div class="stop-name" style="display: none;" value="' +
                result[x]["stop_id"] + '">' +
                '<span class="mini-button"></span>' +
                '<span class="stop-name-text">' +
                result[x]["name"] + '</span>' +
                '</div>');
          }

          $('#stops div').each(function( i ) {
            $(this).delay(250).fadeIn();
          });
        }
      });
    };
  }

  function selectBus( bus ){
    busName = $(bus).find('h1').text();

    $('.fullBus').each(function(){
      if ( $(this).find('h1').text() != busName ) {
        $(this).delay(50).slideUp();
      };
    });
  }

  function displayBuses(result) {
    if (result.length == 0) {
      $('#bus_time_display').append('<h4>Sorry no more buses here tonight :(</h4>');
    }

    for (x in result) {
      if ((busName != "") && (result[x]["busName"] != busName)) {
        continue;
      };

      var time = result[x]["departure_time"],
          amOrPm = time[0] < 12 ? 'am' : 'pm',
          hours = time[0] % 12,
          minutes = time[1] < 10 ? '0' + time[1].toString() : time[1],
          parsedTime = ([hours, minutes].join(":")) + amOrPm;

      $('#bus_time_display').append(
        '<div class="fullBus">' +
	  '<div class="bus_and_time">' +
          '<h1>' + result[x]["trip"]["route"] + '</h1>'+
          '<h3>@</h3>' + '<div class="busTime">' + parsedTime +
	  '</div>' +
	  '</div>' +
	  '<div class="headsign">' +
	  result[x]["trip"]["headsign"] + '</div>' +
          '</div>'
      );
    }

    $('#bus_time_display p').each(function( i ) {
      $(this).delay(100).fadeIn();
    });

    $('.fullBus').each(function( i ){
      $(this).on("click", "", function(){
        selectBus(this);
      });
    });

    $('#bus_time_display').slideDown();
    $('#bus_time_display').append('<p><span id="more">next hour</span></p>');
  };

  function next_hour() {
    hourOffset += 1;
    setBuses($('div[class~="selected"]').attr("value"), hourOffset);
  }

  function formattedTime(offset) {
    var currentTime = new Date(),
        formattedTime = {};

    currentTime.setTime(currentTime.getTime() + (offset * 60 * 60 * 1000)),
    formattedTime = {
      date: [
        currentTime.getFullYear(),
        currentTime.getMonth(),
        currentTime.getDate()],
      time: [
        ((currentTime.getHours() + offset) % 24),
        currentTime.getMinutes(),
        0]
    };
    return formattedTime;
  }

  function setBuses(stopId, timeOffset, callback) {
    timeOffset = timeOffset == undefined ? 0 : timeOffset;
    callback = callback == undefined ? function() {} : callback;
    $.ajax({
      url: "/api/stoptimes",
      type: "GET",
      dataType: "json",
      data: {
        'stopId': stopId,
        'time': formattedTime(timeOffset)
      },
      success: function(result) {
        callback();
	$('#bus_time_display').fadeOut('fast', function(){
  	  $('#bus_time_display').empty();
          displayBuses(result);
          $('#more').on("click", "", function(){
            next_hour();
          });
	});
      }
    });
  }

  $('#stops').on("click", "div", function(){
    hourOffset = 0;
    var $self = $(this);

    $('#stops div').each(function() {
      $(this).removeClass("selected");
      $(this).removeClass("success");
    });

    $self.addClass("selected");
    setBuses($self.attr("value"), 0, function() {
      $self.addClass("success");
    });
  });
});
