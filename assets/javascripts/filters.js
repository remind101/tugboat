(function(angular) {
  'use strict';

  var module = angular.module('app.filters', [
    'ng'
  ]);

  module.filter('ansi', function($window, $sce) {
    return function(input) {
      return $sce.trustAsHtml($window.ansi_up.ansi_to_html(input));
    };
  });

})(angular);
