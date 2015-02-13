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
          $('#stops p').each(function ( i ){
            $( this ).fadeOut('fast', function() {
              $( this ).remove();
            });
          });
          for (x in result) {
            $('#stops').append('<p style="display:none;" value="' + result[x]["stopId"] +  '">' + result[x]["name"] + '</p>');
          }

          $('#stops p').each(function( i ) {
            $(this).delay(250).fadeIn();
          });
        }
      });
    };
  }

  function select_bus( bus ){
    busName = $(bus).find('h1').text();

    $('.fullBus').each(function(){
      if ( $(this).find('h1').text() != busName ) {
        $(this).delay(50).slideUp();
      };
    });
  }

  function add_buses(result) {
    if (result.length == 0) {
      $('#bus_time_display').append('<h4>Sorry no more buses here tonight :(</h4>');
    }

    for (x in result) {
      if ((busName != "") && (result[x]["busName"] != busName)) {
        continue;
      };

      var time = result[x]["stop"]["departureTime"],
          amOrPm = 24 >= time[0] >= 12 ? 'am' : 'pm',
          hours = time[0] >= 24 ? time[0] - 24 : time[0],
          parsedTime = ([hours, time[1]].join(":")) + amOrPm;

      $('#bus_time_display').append(
        '<div class="fullBus">' +
	  '<div class="bus_and_time">' +
          '<h1>' + result[x]["trip"]["route"] + '</h1>'+
          '<h3>@</h3>' + '<div class="busTime">' + parsedTime +
	  '</div>' +
	  '</div>' +
	  '<div class="headsign">' +
	  result[x]["trip"]["tripHeadsign"] + '</div>' +
          '</div>'
      );
    }

    $('#bus_time_display p').each(function( i ) {
      $(this).delay(100).fadeIn();
    });

    $('.fullBus').each(function( i ){
      $(this).on("click", "", function(){
        select_bus( this );
      });
    });

    $('#bus_time_display').slideDown();
    $('#bus_time_display').append('<p><span id="more">Next Hour</span></p>');
  };

  // function next_hour() {
  //   console.log('next hour called');

  //   hourOffset += 1

  //   var d = new Date()
  //   hours = d.getHours() + hourOffset
  //   minutes = d.getMinutes()

  //   console.log(hours)
  //   console.log(minutes)

  //   $.ajax({
  //     url: "/busTimes/",
  //     type: "POST",
  //     dataType: "json",
  //     data: {
  //       'stopId': $( 'p[class="selected"]' ).attr("value"),
  //       'hours': hours,
  //       'minutes': minutes,
  //     },

  //     complete: function() {
  //     },

  //     success: function( result ) {
  //       	    $('#bus_time_display').fadeOut('fast', function(){
  // 			$('#bus_time_display').empty()

  // 			add_buses( result );

  //       $('#more').on("click", "", function(){
  //         next_hour();
  //       });
  //       	    });
  //     },

  //     error: function() {
  //     },
  //   });
  // };

  $('#stops').on("click", "p", function(){
    var busName = "",
        hourOffset = 0,
        currentTime = (new Date()).toJSON();

    $('#stops p').each(function() {
      $(this).removeClass("selected");
    });
    $(this).addClass("selected");

    $.ajax({
      url: "/api/stoptimes",
      type: "GET",
      dataType: "json",
      data: {
        'stopId': $(this).attr("value"),
        'time': currentTime
      },
      success: function(result) {
	$('#bus_time_display').fadeOut('fast', function(){
  	  $('#bus_time_display').empty();
  	  add_buses(result);

          $('#more').on("click", "", function(){
            // next_hour();
          });
	});
      }
    });
  });
});
