module = angular.module('impac.components.widgets-settings.source-selector',[])

module.directive('settingSourceSelector', ($templateCache, $timeout, ImpacMainSvc, ImpacUtilities, ImpacTheming) ->
  return {
    restrict: 'A',
    scope: {
      parentWidget: '='
      deferred: '='
    },
    template: $templateCache.get('widgets-settings/source-selector.tmpl.html'),

    link: (scope) ->
      w = scope.parentWidget

      # TODO: Will there be a multi-org use case?
      scope.mode ||= 'single'
      scope.singleOrgMode = -> scope.mode == 'single'
      scope.multiOrgMode = -> scope.mode == 'multiple'

      scope.selectedApps = {}
      setting = {}
      setting.key = "source-selector"

      setting.initialize = ->
        $timeout ->
          retrieveAppInstances()
          return true

      setting.toMetadata = ->
        appInstanceId = _.compact(_.map(scope.selectedApps, (checked, uid) ->
          return null if uid == 'prm-records-only'
          uid if checked
        ))

        { app_instance_id: appInstanceId }

      resetSelectedApps = -> scope.selectedApps = _.mapValues(scope.selectedApps, -> false)
      updateAppInstances = (appInstances, primary) ->
        valuesPresent = _.find(appInstances, (hash) ->
          # We push at the same time so we can check for one
          hash.value == 'prm-records-only'
        )
        if valuesPresent then appInstances else appInstances.push(primary)

      retrieveAppInstances = ->
        appInstances = _.find(w.configOptions.selectors, (selector) ->
	        return selector.name == 'app_instances'
        ).options

        # Used as a 'reset' switch to filter on primary records only
        primary =
          'value': 'prm-records-only'
          'label': 'Primary Only'

        # TODO: re-include manual selector?
        if appInstances then updateAppInstances(appInstances, primary) else (appInstances = [primary])

        scope.organizationApps = appInstances

      scope.isApplicationSelected = (app_uid) ->
        !!scope.selectedApps[app_uid]

      scope.toggleSelectApplication = (app_uid) ->
        resetSelectedApps()
        scope.selectedApps[app_uid] = true

      w.settings.push(setting)

      # Setting is ready: trigger load content
      # ------------------------------------
      scope.deferred.resolve(setting)
  }
)
