# Europa

*Prescriptive Talos configuration helpers*

[![Hippocratic License HL3-CORE](https://img.shields.io/static/v1?label=Hippocratic%20License&message=HL3-CORE&labelColor=5e2751&color=bc8c3d)](https://firstdonoharm.dev/version/3/0/core.html)

Europa constrains the Talos model for state machines:

- State transitions are driven by an event stream
- Transitions conditions and actions are uniform with respect to the target state
- The context must be an initialized with a `state` property that’s an instance of an Observable
- The state includes `forward` and `back` properties to support forward and back transitions

If you don’t need or want these features, you should use Talos directly.

## API

Machines are constructed using the `make` function by providing dictionaries for the states and transitions.

```coffeescript
import Europa from "@dashkite/europa"

import transitions from "./transitions"
import states from "./states"

machine = Europa.make { states, transitions }
```

A machine can be started by providing the initial state, returning the event stream that drives it:

```coffeescript
state = Observable.from forward: [], back: []
events = await Europa.start { state, machine }
events.enqueue name: "home"
```

## States

TBD

## Transitions

TBD

## Navigation

TBD
