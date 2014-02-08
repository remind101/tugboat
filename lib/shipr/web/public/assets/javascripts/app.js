(function(angular) {
  'use strict';

  var module = angular.module('app', [
    'ng',
    'ngResource',
    'ui.router'
  ]);

  module.config(function($locationProvider, $stateProvider) {
    $locationProvider.html5Mode(true);

    $stateProvider
      .state('app', {
        'abstract': true,
        views: {
          header: { templateUrl: 'header.html' },
          content: { templateUrl: 'content.html' }
        }
      })

      .state('app.jobs', {
        'abstract': true,
        templateUrl: 'jobs.html'
      })

      .state('app.jobs.list', {
        url: '/',
        controller: 'JobsListCtrl',
        templateUrl: 'jobs/list.html',
        resolve: {
          jobs: function($stateParams, Jobs) {
            return Jobs.all();
          }
        }
      })

      .state('app.jobs.detail', {
        url: '/:jobId',
        controller: 'JobsDetailCtrl',
        templateUrl: 'jobs/detail.html',
        resolve: {
          job: function($stateParams, Jobs) {
            return Jobs.find(parseInt($stateParams.jobId));
          }
        }
      });
  });

  module.run(function($rootScope, $log) {
    $rootScope.$on('$stateChangeError', function(event, toState, toParams, fromState, fromParams, error) {
      $log.error(error);
    });
  });

  module.factory('pusher', function($window) {
    var api_key = $window.$("meta[name='pusher.key']").attr('content');

    return new Pusher(api_key);
  });

  module.factory('subscribeLogs', function(pusher) {
    var channel = pusher.subscribe('private-job');

    return function(scope, job) {
      channel.bind('output', function(data) {
        if (data.id == job.id) {
          scope.$apply(function() {
            job.output += data.output;
          });
        }
      });

      return job;
    };
  });

  module.factory('Jobs', function($resource, $q) {
    var resource = $resource('/api/deploys/:jobId', { jobId: '@id' });

    function find(id) {
      var deferred = $q.defer();

      var job = resource.get({ jobId: id }, function() {
        if (job) {
          deferred.resolve(job);
        } else {
          deferred.reject();
        }
      });

      return deferred.promise;
    };

    function all() {
      var deferred = $q.defer();

      var jobs = resource.query(function() {
        deferred.resolve(jobs);
      });

      return deferred.promise;
    };

    return {
      find: find,
      all: all
    };
  });

  module.controller('JobsListCtrl', function($scope, jobs) {
    $scope.jobs = jobs;
  });

  module.controller('JobsDetailCtrl', function($scope, job, subscribeLogs) {
    $scope.job = subscribeLogs($scope, job);
  });

})(angular);
