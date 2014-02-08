(function(angular) {
  'use strict';

  var module = angular.module('app.services', [
    'ng',
    'ngResource'
  ]);

  /**
   * A pusher client service.
   */
  module.factory('pusher', function($window) {
    var api_key = $window.$("meta[name='pusher.key']").attr('content');

    return new Pusher(api_key);
  });

  module.factory('Job', function(jobEvents) {
    function Job(attributes){
      this.setAttributes(attributes);
    }

    _.extend(Job.prototype, {
      /**
       * Set the attributes on this model.
       *
       * @param {Object} attributes
       */
      setAttributes: function(attributes) {
        var job = this;

        _.each(attributes, function(value, key) {
          job[key] = value;
        });
      },

      /**
       * Update the attributes from pusher.
       *
       * @param {Object} attributes
       */
      updateAttributesFromPusher: function(attributes) {
        this.setAttributes(_.omit(attributes, 'output'));
      },

      /**
       * Append some log output.
       *
       * @param {String} output
       */
      appendOutput: function(output) {
        this.output += output;
      },

      /**
       * Whether or not the job has started to be worked on.
       *
       * @return {Boolean}
       */
      isStarted: function() {
        return !!this.output.length;
      },

      /**
       * Whether or not the job is queueud.
       *
       * @return {Boolean}
       */
      isQueued: function() {
        return !this.isStarted();
      },

      /**
       * Whether or not the job is deploying.
       *
       * @return {Boolean}
       */
      isDeploying: function() {
        return !this.done && this.isStarted();
      },

      /**
       * Whether or not the job successfully deployed.
       *
       * @return {Boolean}
       */
      isDeployed: function() {
        return this.done && this.success;
      },

      /**
       * Whether or not the job failed to deploy.
       *
       * @return {Boolean}
       */
      isFailed: function() {
        return this.done && !this.success;
      }
    });

    return Job;
  });

  /**
   * A service to bind pusher events to a job.
   */
  module.factory('jobEvents', function(pusher) {
    var channels = {};

    function subscribe(scope, job) {
      var channel = channels[job.id] = channels[job.id] || pusher.subscribe('private-job-' + job.id);

      channel.bind('output', function(data) {
        scope.$apply(function() {
          job.appendOutput(data.output);
        });
      });

      channel.bind('complete', function(data) {
        scope.$apply(function() {
          job.updateAttributesFromPusher(data);
        });
      });

      return job;
    };

    return {
      subscribe: subscribe
    };
  });

  /**
   * A service for retrieving jobs.
   */
  module.factory('Jobs', function($resource, $q, Job) {
    var resource = $resource('/api/deploys/:jobId', { jobId: '@id' });

    function find(id) {
      var deferred = $q.defer();

      var job = resource.get({ jobId: id }, function() {
        if (job) {
          deferred.resolve(new Job(job));
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

})(angular);
