---
sidebar_position: 3
---
    
# MobX Observer

```js
// For test only


const reactionStacks = [];

const targetsMap = new WeakMap();

function track(target, key) {
    const currentReaction = reactionStacks[reactionStacks.length - 1];

    if (!currentReaction) return;

    let targetMap = targetsMap.get(target);
    if (!targetMap) {
        targetMap = new Map();
        targetsMap.set(key, targetMap);
    }

    let depsSet = targetMap.get(key);
    if (!depsSet) {
        depsSet = new Set();
        targetMap.set(key, depsSet);
    }

    depsSet.add(currentReaction);
}

function trigger(target, key) {
    const targetMap = targetsMap.get(target);
    if (!targetMap) return;

    const depsSet = targetMap.get(key);
    if (!depsSet) return;

    const depsToRun = [...depsSet];
    depsToRun.forEach((deps) => {
        deps.run();
    });

}

function observable(obj) {
    return new Proxy(obj, {
        get(target, key, receiver) {
            track(target, key);
            return Reflect.get(target, key, receiver);
        },
        
        set(target, key, newValue, receiver) {
            trigger(target, key);
            return Reflect(target, key, newValue, receiver);
        }
    })
}

class Reaction {
    constructor(fn) {
        this.fn = fn
    }

    run() {
        reactionStacks.push(this);

        try {
            this.fn();
        } finally {
            reactionStacks.pop();
        }
    }

    track(cb) {
        cb ();
    }
}

function observe(fn) {
    const reaction = new Reaction(() => reaction.track(fn));
    reaction.run();
}

const state = observable({
    name: 'hello world',
    count: 1
});

observe(() => {
    console.log('count value is ', state.count);
});
```


<div style={{textAlign: 'right'}}><small style={{color: 'grey'}}>last modified at August 28, 2025 17:17</small></div>
      