//= require ./ansi_up
//= require ./directives
//= require ./services
//= require ./filters
//= require ./controllers
//= require_self

(function(angular) {
  'use strict';

  var module = angular.module('app', [
    'ng',
    'ngSanitize',
    'ui.router',
    'app.directives',
    'app.services',
    'app.filters',
    'app.controllers'
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
          jobs: function(Job) {
            return Job.all();
          }
        }
      })

      .state('app.jobs.detail', {
        url: '/deploys/:jobId',
        controller: 'JobsDetailCtrl',
        templateUrl: 'jobs/detail.html',
        resolve: {
          job: function($stateParams, Job) {
            return Job.find($stateParams.jobId);
          }
        }
      });
  });

  module.run(function($rootScope, $log) {
    $rootScope.$on('$stateChangeError', function(event, toState, toParams, fromState, fromParams, error) {
      $log.error(error);
    });
  });

})(angular);
