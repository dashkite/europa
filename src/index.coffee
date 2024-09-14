import * as Fn from "@dashkite/joy/function"
import * as Arr from "@dashkite/joy/array"
import * as Type from "@dashkite/joy/type"
import { Queue } from "@dashkite/joy/iterable"
import { Machine as $Machine, Async } from "@dashkite/talos"
import * as Format from "@dashkite/rio-arriba/format"

Default =

  make: ( name ) ->
    when: Default.when name
    run: Default.run name

  when: ( target ) -> 
    ( talos, { name }) -> name == target

  run: ( name ) ->
    ( talos ) ->
      title = Format.title name
      talos.context.state.plan ( state ) ->
        Object.assign state, { name, title }

navigate = ( action ) ->
  
  ( talos, event ) ->

    await action talos, event

    if Type.isString talos.state
      talos.context.state.plan Fn.tee ( state ) ->
        state.forward = []
        state.back.push talos.state

apply = ( action ) ->

  ( talos, events ) ->
    await action talos, events
    await talos.context.state.commit()

Machine =

  make: ( specifier ) ->
  
    do ({ state, transitions, transition, _transitions, _result } = {}) ->

      $Machine.make specifier.name, do ->

        _transitions = {}
        _result = {}

        for state, transitions of specifier.states

          _result[ state ] = {}

          for transition in transitions

            _transition = do ->
              _transitions[ transition ] ?= Object.assign ( Default.make transition ),
                specifier.transitions[ transition ]
            
            _result[ state ][ transition ] =
              when: _transition.when
              run: apply navigate _transition.run

          _result[ state ].back =
            when: Default.when "back"
            move: ( talos, event ) ->
              _state = talos.state
              _back = talos.context.state.get().back
              while ( _back.length > 0 ) && ( _state == talos.state )
                talos.state = _back.pop()
              talos.context.state.plan Fn.tee ( state ) ->
                state.back = _back
                state.forward.push _state
              _action = apply _transitions[ talos.state ].run
              _action talos, name: talos.state, context: {}

          _result[ state ].forward =
            when: Default.when "forward"
            move: ( talos, event ) ->
              _state = talos.state
              talos.state = talos.context.state.get().forward.pop()
              talos.context.state.plan Fn.tee ( state ) ->
                state.forward.pop()
                state.back.push _state
              _action = apply _transitions[ talos.state ].run
              _action talos, name: talos.state, context: {}

        _result

  start: ({ state, machine }) ->

    queue = do Queue.make

    events = do ->
      loop
        event = await do queue.dequeue
        yield event

    context = { state }

    do ->

      for await talos from Async.start machine, context, events
        if talos.error?
          console.error talos.error
          console.warn { talos }
    queue

export default Machine