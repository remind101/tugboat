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

  module.factory('Job', function($resource, jobEvents) {
    var resource = $resource(
      '/api/deploys/:jobId',
      { jobId: '@id' },
      { restart: { method: 'POST', url: '/api/deploys/:jobId/restart' } }
    );

    function Job(attributes){
      this.setAttributes(attributes);

      this.restart = attributes.$restart;
    }

    /**
     * Get a single job.
     */
    Job.find = function(id) {
      return resource.get({ jobId: id }).$promise.then(function(job) {
        return new Job(job);
      });
    };

    /**
     * Get all jobs.
     */
    Job.all = function() {
      return resource.query().$promise;
    };

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
          job.setAttributes(data);
        });
      });

      return job;
    };

    return {
      subscribe: subscribe
    };
  });

})(angular);
