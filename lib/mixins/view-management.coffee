Mixin = require 'mixto'
MinimapView = require '../minimap-view'

# Public: Provides methods to manage minimap views per pane.
module.exports =
class ViewManagement extends Mixin
  # Internal: Stores each MinimapView using the id of their PaneView
  minimapViews: {}

  # Public: Updates all views currently in use.
  updateAllViews: ->
    view.onScrollViewResized() for id,view of @minimapViews

  # Public: Returns the {MinimapView} object associated to the pane containing
  # the passed-in {EditorView}.
  #
  # editorView - An {EditorView} instance
  #
  # Returns the {MinimapView} object associated to the pane containing
  # the passed-in {EditorView}.
  minimapForEditorView: (editorView) ->
    @minimapForPaneView(editorView?.getPane())

  # Internal: Destroys all views currently in use.
  destroyViews: ->
    view.destroy() for id, view of @minimapViews
    @eachEditorViewSubscription?.off()
    @minimapViews = {}

  # Internal: Registers to each pane view existing or to be created and creates
  # a {MinimapView} instance for each.
  createViews: ->
    # When toggled we'll look for each existing and future editors thanks to
    # the `eacheditorView` method. It returns a subscription object so we'll
    # store it and it will be used in the `deactivate` method to removes
    # the callback.
    @eachEditorViewSubscription = atom.workspaceView.eachEditorView (editorView) =>
      editorId = editorView.editor.id
      view = new MinimapView(editorView)

      @minimapViews[editorId] = view
      @emit('minimap-view:created', {view})

      editorView.editor.on 'destroyed', =>
        view = @minimapViews[editorId]

        if view?
          @emit('minimap-view:will-be-destroyed', {view})

          view.destroy()
          delete @minimapViews[editorId]
          @emit('minimap-view:destroyed', {view})
