define [
    'c/controllers'
    'd/ngSmoothie'
  ],
(controllers) ->
  'use strict'

  controllers.controller 'system', ['$scope', '$interval', '$routeParams', ($scope, $interval, $routeParams) ->
    $scope.series =
      proc:
        'r': 'Number of processes waiting for run time'
        'b': 'Number of processes in uninterruptible sleep'
      mem:
        'swpd': 'Amount of virtual memory used'
        'free': 'Amount of idle memory'
        'buff': 'Amount of memory used as buffers'
        'cache': 'Amount of memory used as cache'
      swap:
        'si': 'Amount of memory swapped in from disk'
        'so': 'Amount of memory swapped to disk'
      io:
        'bi': 'Blocks received from a block device (blocks/s)'
        'bo': 'Blocks sent to a block device (blocks/s)'
      sys:
        'in': 'Number of interrupts per second, including the clock',
        'cs': 'Number of context switches per second'

      'cpu':
        'us': 'Time spent running non-kernel code (user time, including nice time)'
        'sy': 'Time spent running kernel code (system time)'
        'id': 'Time spent idle'
        'wa': 'Time spent waiting for IO'

  ]