co = require 'co'

getSignature = (fn)->
    params = /\(([\s\S]*?)\)/.exec fn
    if params and params[1].trim()
        params[1].split(',').map (x)-> x.trim()
    else
        []

merge = (base, more)->
    ret = {}
    if "object" is typeof base
        for own key,val of base
            ret[key] = val
    if "object" is typeof more
        for own key,val of more
            ret[key] = val
    ret

init = (defaultHandler)->

    defaultHandler or= (name, kwargs)-> throw Error "Method not registered: #{name}"

    handlers = {}
    signatures = {}
    defaults = {}

    _register = (name, handler, defaultParams)->
        if handler.constructor.name is 'GeneratorFunction'
            signatures[name] = getSignature handler
            handler = co.wrap handler
        handlers[name] = handler
        defaults[name] = defaultParams if defaultParams

    register = (args...)->
        if args.length is 2
            if 'function' is typeof args[1]
                [name, handler] = args
                _register name, handler
            else
                [namespace, methods] = args
                throw Error "Second paramter should be an object" unless 'object' is typeof methods
                for own name, handler of methods
                    if 'function' is typeof handler
                        _register "#{namespace}.#{name}", handler, methods["#{name}_defaults"]
        else if args.length is 3
            [method, defaultParams, handler] = args
            _register method, handler, defaultParams
        else
            throw Error "Incorrect call to register"

    dispatch = (name, kwargs, context)->
        if name not of handlers
            return defaultHandler name, kwargs
        if 'object' isnt typeof kwargs
            throw Error 'Parameters must be passed as an object'
        signatures[name] = getSignature handlers[name] unless name of signatures
        preparedParams = []
        for varname in Object.keys kwargs
            throw Error "Unexpected parameter: #{varname}" unless varname in signatures[name]
        for varname in signatures[name]
            if varname not of kwargs
                if defaults[name] and varname of defaults[name]
                    preparedParams.push defaults[name][varname]
                else if varname is "kwargs"
                    preparedParams.push merge defaults[name], kwargs
                else
                    throw Error "Parameter missing: #{varname}"
            else
                preparedParams.push kwargs[varname]
        handlers[name].apply context, preparedParams

    register: register
    dispatch: dispatch

module.exports = init
