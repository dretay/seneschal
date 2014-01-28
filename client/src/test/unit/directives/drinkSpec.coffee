# define [
#   "angular"
#   "angularMocks"
#   "app"
#   'd/drink'
# ],
# (angular, mocks, app) ->
#   describe "Unit::Directives Drink", ->

#     scope = null
#     elm = null

#     beforeEach angular.mock.module('app')

#     beforeEach module 'templates'

#     beforeEach inject ($rootScope,$compile)->
#       elm = angular.element('<form name="form"><drink recipe="recipe" save=""></drink></form>')
#       scope = $rootScope

#       scope.recipe =
#         title: "sarsaparilla"
#         recipeId: 1
#         type: "DRINK"

#       $compile(elm)(scope)
#       scope.$digest()

#     it "should display the title text properly", ->
#       chai.expect(elm.html()).to.match(/sarsaparilla/i)