###*
# Angular Selectize2
# https://github.com/machineboy2045/angular-selectize
#
###

angular.module('selectize', []).value('selectizeConfig', {}).directive 'selectize', [
  'selectizeConfig'
  (selectizeConfig) ->
    {
      restrict: 'EA'
      require: '^ngModel'
      scope:
        ngModel: '='
        config: '=?'
        options: '=?'
        ngDisabled: '='
        ngRequired: '&'
      link: (scope, element, attrs, modelCtrl) ->
        selectize = undefined
        settings = angular.extend({}, Selectize.defaults, selectizeConfig, scope.config)
        scope.options = scope.options or []
        scope.config = scope.config or {}

        isEmpty = (val) ->
          val == undefined or val == null or !val.length
          #support checking empty arrays

        toggle = (disabled) ->
          if disabled then selectize.disable() else selectize.enable()
          return

        validate = ->
          isInvalid = (scope.ngRequired() or attrs.required or settings.required) and isEmpty(scope.ngModel)
          modelCtrl.$setValidity 'required', !isInvalid
          return

        setSelectizeOptions = (curr, prev) ->
          angular.forEach prev, (opt) ->
            if curr.indexOf(opt) == -1
              value = opt[settings.valueField]
              selectize.removeOption value, true
            return
          selectize.addOption curr, true
          setSelectizeValue()
          return

        setSelectizeValue = ->
          validate()
          selectize.$control.toggleClass 'ng-valid', modelCtrl.$valid
          selectize.$control.toggleClass 'ng-invalid', modelCtrl.$invalid
          selectize.$control.toggleClass 'ng-dirty', modelCtrl.$dirty
          selectize.$control.toggleClass 'ng-pristine', modelCtrl.$pristine
          if !angular.equals(selectize.items, scope.ngModel)
            selectize.setValue scope.ngModel, true
          return

        settings.onChange = (value) ->
          `var value`
          value = angular.copy(selectize.items)
          if settings.maxItems == 1
            value = value[0]
          modelCtrl.$setViewValue value
          if scope.config.onChange
            scope.config.onChange.apply this, arguments
          return

        settings.onOptionAdd = (value, data) ->
          if scope.options.indexOf(data) == -1
            scope.options.push data
            if scope.config.onOptionAdd
              scope.config.onOptionAdd.apply this, arguments
          return

        settings.onInitialize = ->
          selectize = element[0].selectize
          scope.selectizeObject = selectize
          setSelectizeOptions scope.options
          #provides a way to access the selectize element from an
          #angular controller
          if scope.config.onInitialize
            scope.config.onInitialize selectize
          scope.$watchCollection 'options', setSelectizeOptions
          scope.$watch 'ngModel', setSelectizeValue
          scope.$watch 'ngDisabled', toggle
          return

        element.selectize settings
        element.on '$destroy', ->
          if selectize
            selectize.destroy()
            element = null
          return

        scope.$on "selectize:setSearchInput", (e, newVal) ->
          newVal = "" unless newVal
          
          if scope.selectizeObject and selectizeWrapper = scope.selectizeObject.$wrapper
            searchInput = selectizeWrapper.find('.selectize-input input')

            if searchInput.length > 0
              searchInput.val(newVal)
        return

    }
]
