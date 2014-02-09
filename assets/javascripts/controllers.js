(function(angular) {
  'use strict';

  var module = angular.module('app.controllers', [
    'ng'
  ]);

  module.controller('JobsListCtrl', function($scope, jobs) {
    $scope.jobs = jobs;
  });

  module.controller('JobsDetailCtrl', function($scope, $state, job, jobEvents) {
    $scope.job = jobEvents.subscribe($scope, job);

    $scope.restart = function() {
      $scope.job.restart().then(function(job) {
        $state.go('app.jobs.detail', { jobId: job.id });
      });
    };
  });

})(angular);
