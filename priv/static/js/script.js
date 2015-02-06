$(document).ready(function(){
  var typingTimer;
  var doneTypingInterval = 800;
  var hourOffset = 0;
  var busName = "";

  $('#search').keyup(function(){
    clearTimeout(typingTimer);
    if ($('#search').val()) {
      typingTimer = setTimeout(search, doneTypingInterval);
    }
  });

  function search() {
    searchTerm = $('#search').val();

    if (searchTerm.length > 3) {
      $.ajax({
        url: "/api/find",
        type: "GET",
        dataType: "json",
        data: {
          "name": searchTerm
        },

        complete: function() {
          console.log('glory be');
        },

        success: function( result ) {
          console.log('glory be 2');
          $('#stops p').each(function ( i ){
            $( this ).fadeOut('fast', function() {
              $( this ).remove();
            });
          });
          console.log( result );
          for (x in result) {
            $('#stops').append('<p style="display:none;" value="' + result[x]["stopId"] +  '">' + result[x]["name"] + '</p>');
          }

          $('#stops p').each(function( i ) {
            $( this ).delay(250).fadeIn();
          });
        },

        error: function() {}
    	});
    };

  };

  function select_bus( bus ){
    busName = $(bus).find('h1').text();

    $('.fullBus').each(function(){
      if ( $(this).find('h1').text() != busName ) {
        $(this).delay(50).slideUp();
      };
    })
  }

  function add_buses( result ) {
	  console.log('add buses called')

    if (result["buses"].length == 0) {
      $('#bus_time_display').append('<h4>Sorry no more buses here tonight :(</h4>')
    }

    for (x in result["buses"]) {
      if ((busName != "") && (result["buses"][x]["busName"] != busName)) {
        continue
      };

      $('#bus_time_display').append('<div class="fullBus">' +
												'<div class="bus_and_time">' +
                        '<h1>' + result["buses"][x]["busName"] + '</h1>'+
                        '<h3>@</h3>' + '<div class="busTime">' + result["buses"][x]["time"] +
												'</div>' +
												'</div>' +
												'<div class="headsign">' +
												result["buses"][x]["tripHeadsign"] + '</div>' +
                        '</div>')
      }

    $('#bus_time_display p').each(function( i ) {
      $( this ).delay(100).fadeIn()
    });

    $('.fullBus').each(function( i ){
      $( this ).on("click", "", function(){
        select_bus( this )
      })
    })

		$('#bus_time_display').slideDown();

    $('#bus_time_display').append('<p><span id="more">Next Hour</span></p>');
  };

  function next_hour() {
    console.log('next hour called');

    hourOffset += 1

    var d = new Date()
    hours = d.getHours() + hourOffset
    minutes = d.getMinutes()

    console.log(hours)
    console.log(minutes)

    $.ajax({
      url: "/busTimes/",
      type: "POST",
      dataType: "json",
      data: {
        'stopId': $( 'p[class="selected"]' ).attr("value"),
        'hours': hours,
        'minutes': minutes,
      },

      complete: function() {
      },

      success: function( result ) {
		    $('#bus_time_display').fadeOut('fast', function(){
  			$('#bus_time_display').empty()

  			add_buses( result );

        $('#more').on("click", "", function(){
          console.log('hello')
          next_hour();
        });
		    });
      },

      error: function() {
      },
    });
  };

  $('#stops').on("click", "p", function(){
    busName = ""

    hourOffset = 0

    console.log ($( this ).attr("value"))
  	$('#stops p').each(function() {
  		$( this ).removeClass("selected")
  	})

    $( this ).addClass("selected")

    var d = new Date()
    hours = d.getHours()
    minutes = d.getMinutes()

    $.ajax({
      url: "/busTimes/",
      type: "POST",
      dataType: "json",
      data: {
        'stopId': $( this ).attr("value"),
        'hours': hours,
        'minutes': minutes,
      },

      complete: function() {
      },

      success: function( result ) {
		    $('#bus_time_display').fadeOut('fast', function(){
  			$('#bus_time_display').empty()

  			add_buses( result );

        $('#more').on("click", "", function(){
          console.log('hello')
          next_hour();
        });
		    });
      },

      error: function() {
      },
    });
  });
});
