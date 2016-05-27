/*
 *  Constants
 */
var legendTemplate = '<div class="btn-group-vertical" role="group"> \
                        <% for (var i=0; i<datasets.length; i++){%> \
                          <button type="button" id="<%=datasets[i].label%>" class="btn btn-default dropdown-toggle" data-toggle="dropdown" aria-expanded="false" onclick="removePokemon(this.id)" style="color: <%=datasets[i].strokeColor%>;"> \
                          <%if(datasets[i].label){%> \
                            <%=datasets[i].label%> \
                          <%}%> \
                          <span class="glyphicon glyphicon-remove" onclick="hideErrorMessage()"></button> \
                        <%}%> \
                      </div>';

var options = { 
  pointDot: false, 
  datasetFill: false,
  showTooltips: false,
  legendTemplate: legendTemplate,
  scaleLabel: "<%=value%>%"
};

var preferredTiers = ["ou", "ubers", "uu", "ru", "nu", "pu", "lc", "doublesou"];

/*
 * Variables that represent of the state of the page
 */
var generation;
var tier;
var elo;

var metadata;

var pokemonColours = {};

var freeColours = [
  "rgb(255,   0,   0)",
  "rgb(  0, 255,   0)",
  "rgb(  0,   0, 255)",
  "rgb(  0,   0,   0)",
  "rgb(  0, 255, 255)",
  "rgb(255,   0, 255)"
];

/*
 * Code
 */
$(document).ready( function () {

  $.ajaxSetup({
    async: false
  });

  $.getJSON("/api/v1/metadata", function(data) {
    metadata = data;
  });

  largest_gen = Math.max.apply(Math, Object.keys(metadata));
  changeGeneration(largest_gen, null);
});

var changeGeneration = function(gen) {
  generation = gen;

  // If current_tier doesn't apply to this generation choose a more appropriate one
  var best_tier = metadata[generation][tier] != undefined ? tier : "ou";
  changeTier(best_tier);
}

var changeTier = function(tr) {
  tier = tr;

  var best_elo = metadata[generation][tier][elo] != undefined ? elo : 0;
  changeElo(best_elo);
};

var changeElo = function(el) {
  elo = el;

    // Replace the pokemon data
  $.getJSON("/api/v1/pokemon?generation="+generation+"&tier="+tier+"&min_rank="+elo, function(data) {
    searchablePokemon = data;
  });

  $('#pickerColumn').empty();
  $('#pickerColumn').html(
    '<div id="pokemonPicker" style="text-align: center;"> \
      <input id="pickerInput" class="typeahead" type="text" placeholder="Add a pokemon..."> \
    </div>'
  );

  $('#pokemonPicker .typeahead').typeahead({
      hint: false,
      highlight: true,
      minLength: 3
    },
    {
      name: 'pokemon',
      displayKey: 'value',
      source: substringMatcher(searchablePokemon)
  }).bind('typeahead:selected', function($e, pokemon){
    $('#pickerInput').val('');
    addPokemon(pokemon.value)
  });

  // Replace the value data (find the pokemon that are still in the new tier, generation, make a usage request for those)
  Object.keys(pokemonColours).forEach(function(pokemon) {
    if (searchablePokemon.indexOf(pokemon) < 0) {
      removePokemon(pokemon);
    } 
  });

  refreshPage();

}

var refreshPage = function() {
  var pokemonToPlot = Object.keys(pokemonColours);
  
  displayUsageInfo();

  if(pokemonToPlot.length >= 6) {
    $('#pokemonPicker').hide();
  } else if(pokemonToPlot.length > 0) {
    $('#pickerInput').val('');
    $('#pokemonPicker').show();
  } else {
    hideChart();
    return;
  }

  redrawChart();
};

var redrawChart = function() {
  var graphData;
  $.getJSON("/api/v1/usage?generation="+generation+"&tier="+tier+"&min_rank="+elo+"&pokemon="+Object.keys(pokemonColours).join(), function(data) {
    graphData = data;
  });

  hideUsageInfo();
  showChart();

  var pokemonData = $.map(Object.keys(graphData.data), function(name, values) {
    var monthsData = graphData.data[name];

    return {
      label: name,
      strokeColor: pokemonColours[name],
      lineTension: 1,
      data: monthsData
    }
  });

  var data = {
    labels: graphData.dates,
    datasets: pokemonData
  };

  var usageChart = new Chart($('#usageChart').get(0).getContext("2d")).Line(data, options);

  $('#usageLegend').html(usageChart.generateLegend())
};

var addPokemon = function(name) {
  if(pokemonColours[name]) {
    showErrorMessage(name + " is already on the chart!");
    return;
  }

  var newColor = freeColours.shift();
  pokemonColours[name] = newColor;

  refreshPage();
};

var removePokemon = function(name) {
    freeColours.unshift(pokemonColours[name]);
    delete pokemonColours[name];
    refreshPage();
};

var displayUsageInfo = function() {
  $('#tierSmall').html("Usage statistics for Gen "+generation+" "+tier);
  $('#tierSelected').html("You currently have the "+tier+" tier selected, to change tier, click on the dropdown on the right.")
  
  // Setup the generation dropdown
  $('#generationDropdown').html(generation+'\n<span class="caret"></span>');

  var genul = $('#generationul');
  genul.empty();
  var gens = Object.keys(metadata);
  gens.sort();
  gens.forEach(function(gen) {
    genul.append('<li role="presentation"><a role="menuitem" tabindex="-1" id="'+gen+'" onclick="changeGeneration(this.id)">'+gen+'</a></li>')
  });

  // Setup the tier dropdown
  $('#tierDropDown').html(tier+'\n<span class="caret"></span>');

  var tierul = $('#tierul');
  tierul.empty();
  var tiers = Object.keys(metadata[generation]);
  
  preferredTiers.forEach(function(pTier) {
    var index = tiers.indexOf(pTier);
    if(index > -1) {
      tierul.append('<li role="presentation"><a role="menuitem" tabindex="-1" id="'+pTier+'" onclick="changeTier(this.id)">'+pTier+'</a></li>')
      tiers.splice(index, 1);
    }
  });

  if(tiers.length > 0) {
    tierul.append('<li role="separator" class="divider"></li>')
    tiers.sort()
    tiers.forEach(function(tier) {
      tierul.append('<li role="presentation"><a role="menuitem" tabindex="-1" id="'+tier+'" onclick="changeTier(this.id)">'+tier+'</a></li>');
    }); 
  }

  // Setup the elo dropdown
  $('#eloDropDown').html(elo+'\n<span class="caret"></span>');

  var eloul = $('#eloul');
  eloul.empty();
  var elos = metadata[generation][tier];
  elos.sort();
  elos.forEach(function(el) {
    eloul.append('<li role="presentation"><a role="menuitem" tabindex="-1" id="'+el+'" onclick="changeElo(this.id)">'+el+'</a></li>')
  });

  $('#usageRow').show();
};

var hideUsageInfo = function() {
  $('#usageRow').hide();
};

var showChart = function() {
  $('#chartRow').show();
};

var hideChart = function() {
  $('#chartRow').hide();
};

var showErrorMessage = function(message) {
  $('#errorMessage').html(message);
  $('#errorMessageRow').show();
};

var hideErrorMessage = function() {
  $('#errorMessageRow').hide();
};

var substringMatcher = function(strs) {
  return function findMatches(q, cb) {
    var matches, substrRegex;
 
    // an array that will be populated with substring matches
    matches = [];
 
    // regex used to determine if a string contains the substring `q`
    substrRegex = new RegExp(q, 'i');
 
    // iterate through the pool of strings and for any string that
    // contains the substring `q`, add it to the `matches` array
    $.each(strs, function(i, str) {
      if (substrRegex.test(str)) {
        // the typeahead jQuery plugin expects suggestions to a
        // JavaScript object, refer to typeahead docs for more info
        matches.push({ value: str });
      }
    });
 
    cb(matches);
  };
};