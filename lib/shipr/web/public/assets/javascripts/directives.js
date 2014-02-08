(function(angular) {
  'use strict';

  var module = angular.module('app.directives', [
    'ng'
  ]);

  /**
   * A directive for building a css3 spinner.
   */
  module.directive('spinner', function() {
    return {
      restrict: 'C',
      link: function(scope, elem) {
        function addRect(i) {
          elem.append('<div class="rect' + i + '"></div> ');
        }

        _(4).times(addRect);
      }
    };
  });

})(angular);
