var app = angular.module('app',[]);

app.controller('MainCtrl', ['$scope','MainService', function ($scope,MainService) {
    
    $scope.convertText = function (conversionText) {
        if (conversionText != null) {
            MainService.convertText(conversionText)
              .then (function success(response){
                  $scope.message = 'Text Converted!';
                  $scope.errorMessage = '';
                  $scope.convertedText = response.data;
              },
              function error(response){
                  $scope.errorMessage = 'Error converting Text!';
                  $scope.message = '';
            });
        }
        else {
            $scope.errorMessage = 'Please enter text to be converted!';
            $scope.message = '';
        }
    }

}]);

app.service('MainService',['$http', function ($http) {	

    this.convertText = function convertText(conversionText){
        return $http({
          method: 'POST',
          url: 'https://demoapp.it-travellers.com/nodeapi/convert',
          data: {conversionText:conversionText}
        });
    }

}]);