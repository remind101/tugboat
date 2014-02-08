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

  module.directive('environmentVariable', function() {
    return {
      restrict: 'EA',
      scope: { var: '@', value: '@' },
      template: '<div class="environment-variable"><span class="var" ng-bind="var"></span>=<span class="value" ng-bind="value"></span></div>'
    };
  });

  /**
   * A directive that for showing environment variables.
   */
  module.directive('environmentVariables', function($compile) {
    return {
      restrict: 'EA',
      scope: { environmentVariables: '=' },
      link: function(scope, elem) {
        _.each(scope.environmentVariables, function(value, key) {
          elem.append($compile('<span environment-variable var="' + key + '" value="' + value + '" />')(scope));
        });
      }
    };
  });

})(angular);
