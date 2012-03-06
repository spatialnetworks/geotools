var sys = require('sys');

(function() {
  /*global PriorityQueue */
  /**
   * @constructor
   * @class PriorityQueue manages a queue of elements with priorities. Default
   * is highest priority first.
   *
   * @param [options] If low is set to true returns lowest first.
   */
  Procedure = function(options) {
	var currentStep = -1;
	var steps = [];
    /**
     * @private
     
    var sort = function() {
      contents.sort(sortStyle);
      sorted = true;
    };

	*/
	
	
    var self = {
		steps: steps,
		currentStep: -1,
		
      next: function(arg) {
		if (this.currentStep + 1 < this.steps.length) {
			this.currentStep++;

			this.steps[this.currentStep](arg);
		}
      },
    };

    return self;
  };
})();
