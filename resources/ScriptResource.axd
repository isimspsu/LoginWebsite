// Name:        MicrosoftAjax.debug.js
// Assembly:    System.Web.Extensions
// Version:     4.0.0.0
// FileVersion: 4.8.4110.0
//-----------------------------------------------------------------------
// Copyright (C) Microsoft Corporation. All rights reserved.
//-----------------------------------------------------------------------
// MicrosoftAjax.js
// Microsoft AJAX Framework.
 
Function.__typeName = 'Function';
Function.__class = true;
Function.createCallback = function Function$createCallback(method, context) {
    /// <summary locid="M:J#Function.createCallback" />
    /// <param name="method" type="Function"></param>
    /// <param name="context" mayBeNull="true"></param>
    /// <returns type="Function"></returns>
    var e = Function._validateParams(arguments, [
        {name: "method", type: Function},
        {name: "context", mayBeNull: true}
    ]);
    if (e) throw e;
    return function() {
        var l = arguments.length;
        if (l > 0) {
            var args = [];
            for (var i = 0; i < l; i++) {
                args[i] = arguments[i];
            }
            args[l] = context;
            return method.apply(this, args);
        }
        return method.call(this, context);
    }
}
Function.createDelegate = function Function$createDelegate(instance, method) {
    /// <summary locid="M:J#Function.createDelegate" />
    /// <param name="instance" mayBeNull="true"></param>
    /// <param name="method" type="Function"></param>
    /// <returns type="Function"></returns>
    var e = Function._validateParams(arguments, [
        {name: "instance", mayBeNull: true},
        {name: "method", type: Function}
    ]);
    if (e) throw e;
    return function() {
        return method.apply(instance, arguments);
    }
}
Function.emptyFunction = Function.emptyMethod = function Function$emptyMethod() {
    /// <summary locid="M:J#Function.emptyMethod" />
}
Function.validateParameters = function Function$validateParameters(parameters, expectedParameters, validateParameterCount) {
    /// <summary locid="M:J#Function.validateParameters" />
    /// <param name="parameters"></param>
    /// <param name="expectedParameters"></param>
    /// <param name="validateParameterCount" type="Boolean" optional="true"></param>
    /// <returns type="Error" mayBeNull="true"></returns>
    var e = Function._validateParams(arguments, [
        {name: "parameters"},
        {name: "expectedParameters"},
        {name: "validateParameterCount", type: Boolean, optional: true}
    ]);
    if (e) throw e;
    return Function._validateParams(parameters, expectedParameters, validateParameterCount);
}
Function._validateParams = function Function$_validateParams(params, expectedParams, validateParameterCount) {
    var e, expectedLength = expectedParams.length;
    validateParameterCount = validateParameterCount || (typeof(validateParameterCount) === "undefined");
    e = Function._validateParameterCount(params, expectedParams, validateParameterCount);
    if (e) {
        e.popStackFrame();
        return e;
    }
    for (var i = 0, l = params.length; i < l; i++) {
        var expectedParam = expectedParams[Math.min(i, expectedLength - 1)],
            paramName = expectedParam.name;
        if (expectedParam.parameterArray) {
            paramName += "[" + (i - expectedLength + 1) + "]";
        }
        else if (!validateParameterCount && (i >= expectedLength)) {
            break;
        }
        e = Function._validateParameter(params[i], expectedParam, paramName);
        if (e) {
            e.popStackFrame();
            return e;
        }
    }
    return null;
}
Function._validateParameterCount = function Function$_validateParameterCount(params, expectedParams, validateParameterCount) {
    var i, error,
        expectedLen = expectedParams.length,
        actualLen = params.length;
    if (actualLen < expectedLen) {
        var minParams = expectedLen;
        for (i = 0; i < expectedLen; i++) {
            var param = expectedParams[i];
            if (param.optional || param.parameterArray) {
                minParams--;
            }
        }        
        if (actualLen < minParams) {
            error = true;
        }
    }
    else if (validateParameterCount && (actualLen > expectedLen)) {
        error = true;      
        for (i = 0; i < expectedLen; i++) {
            if (expectedParams[i].parameterArray) {
                error = false; 
                break;
            }
        }  
    }
    if (error) {
        var e = Error.parameterCount();
        e.popStackFrame();
        return e;
    }
    return null;
}
Function._validateParameter = function Function$_validateParameter(param, expectedParam, paramName) {
    var e,
        expectedType = expectedParam.type,
        expectedInteger = !!expectedParam.integer,
        expectedDomElement = !!expectedParam.domElement,
        mayBeNull = !!expectedParam.mayBeNull;
    e = Function._validateParameterType(param, expectedType, expectedInteger, expectedDomElement, mayBeNull, paramName);
    if (e) {
        e.popStackFrame();
        return e;
    }
    var expectedElementType = expectedParam.elementType,
        elementMayBeNull = !!expectedParam.elementMayBeNull;
    if (expectedType === Array && typeof(param) !== "undefined" && param !== null &&
        (expectedElementType || !elementMayBeNull)) {
        var expectedElementInteger = !!expectedParam.elementInteger,
            expectedElementDomElement = !!expectedParam.elementDomElement;
        for (var i=0; i < param.length; i++) {
            var elem = param[i];
            e = Function._validateParameterType(elem, expectedElementType,
                expectedElementInteger, expectedElementDomElement, elementMayBeNull,
                paramName + "[" + i + "]");
            if (e) {
                e.popStackFrame();
                return e;
            }
        }
    }
    return null;
}
Function._validateParameterType = function Function$_validateParameterType(param, expectedType, expectedInteger, expectedDomElement, mayBeNull, paramName) {
    var e, i;
    if (typeof(param) === "undefined") {
        if (mayBeNull) {
            return null;
        }
        else {
            e = Error.argumentUndefined(paramName);
            e.popStackFrame();
            return e;
        }
    }
    if (param === null) {
        if (mayBeNull) {
            return null;
        }
        else {
            e = Error.argumentNull(paramName);
            e.popStackFrame();
            return e;
        }
    }
    if (expectedType && expectedType.__enum) {
        if (typeof(param) !== 'number') {
            e = Error.argumentType(paramName, Object.getType(param), expectedType);
            e.popStackFrame();
            return e;
        }
        if ((param % 1) === 0) {
            var values = expectedType.prototype;
            if (!expectedType.__flags || (param === 0)) {
                for (i in values) {
                    if (values[i] === param) return null;
                }
            }
            else {
                var v = param;
                for (i in values) {
                    var vali = values[i];
                    if (vali === 0) continue;
                    if ((vali & param) === vali) {
                        v -= vali;
                    }
                    if (v === 0) return null;
                }
            }
        }
        e = Error.argumentOutOfRange(paramName, param, String.format(Sys.Res.enumInvalidValue, param, expectedType.getName()));
        e.popStackFrame();
        return e;
    }
    if (expectedDomElement && (!Sys._isDomElement(param) || (param.nodeType === 3))) {
        e = Error.argument(paramName, Sys.Res.argumentDomElement);
        e.popStackFrame();
        return e;
    }
    if (expectedType && !Sys._isInstanceOfType(expectedType, param)) {
        e = Error.argumentType(paramName, Object.getType(param), expectedType);
        e.popStackFrame();
        return e;
    }
    if (expectedType === Number && expectedInteger) {
        if ((param % 1) !== 0) {
            e = Error.argumentOutOfRange(paramName, param, Sys.Res.argumentInteger);
            e.popStackFrame();
            return e;
        }
    }
    return null;
}
 
Error.__typeName = 'Error';
Error.__class = true;
Error.create = function Error$create(message, errorInfo) {
    /// <summary locid="M:J#Error.create" />
    /// <param name="message" type="String" optional="true" mayBeNull="true"></param>
    /// <param name="errorInfo" optional="true" mayBeNull="true"></param>
    /// <returns type="Error"></returns>
    var e = Function._validateParams(arguments, [
        {name: "message", type: String, mayBeNull: true, optional: true},
        {name: "errorInfo", mayBeNull: true, optional: true}
    ]);
    if (e) throw e;
    var err = new Error(message);
    err.message = message;
    if (errorInfo) {
        for (var v in errorInfo) {
            err[v] = errorInfo[v];
        }
    }
    err.popStackFrame();
    return err;
}
Error.argument = function Error$argument(paramName, message) {
    /// <summary locid="M:J#Error.argument" />
    /// <param name="paramName" type="String" optional="true" mayBeNull="true"></param>
    /// <param name="message" type="String" optional="true" mayBeNull="true"></param>
    /// <returns></returns>
    var e = Function._validateParams(arguments, [
        {name: "paramName", type: String, mayBeNull: true, optional: true},
        {name: "message", type: String, mayBeNull: true, optional: true}
    ]);
    if (e) throw e;
    var displayMessage = "Sys.ArgumentException: " + (message ? message : Sys.Res.argument);
    if (paramName) {
        displayMessage += "\n" + String.format(Sys.Res.paramName, paramName);
    }
    var err = Error.create(displayMessage, { name: "Sys.ArgumentException", paramName: paramName });
    err.popStackFrame();
    return err;
}
Error.argumentNull = function Error$argumentNull(paramName, message) {
    /// <summary locid="M:J#Error.argumentNull" />
    /// <param name="paramName" type="String" optional="true" mayBeNull="true"></param>
    /// <param name="message" type="String" optional="true" mayBeNull="true"></param>
    /// <returns></returns>
    var e = Function._validateParams(arguments, [
        {name: "paramName", type: String, mayBeNull: true, optional: true},
        {name: "message", type: String, mayBeNull: true, optional: true}
    ]);
    if (e) throw e;
    var displayMessage = "Sys.ArgumentNullException: " + (message ? message : Sys.Res.argumentNull);
    if (paramName) {
        displayMessage += "\n" + String.format(Sys.Res.paramName, paramName);
    }
    var err = Error.create(displayMessage, { name: "Sys.ArgumentNullException", paramName: paramName });
    err.popStackFrame();
    return err;
}
Error.argumentOutOfRange = function Error$argumentOutOfRange(paramName, actualValue, message) {
    /// <summary locid="M:J#Error.argumentOutOfRange" />
    /// <param name="paramName" type="String" optional="true" mayBeNull="true"></param>
    /// <param name="actualValue" optional="true" mayBeNull="true"></param>
    /// <param name="message" type="String" optional="true" mayBeNull="true"></param>
    /// <returns></returns>
    var e = Function._validateParams(arguments, [
        {name: "paramName", type: String, mayBeNull: true, optional: true},
        {name: "actualValue", mayBeNull: true, optional: true},
        {name: "message", type: String, mayBeNull: true, optional: true}
    ]);
    if (e) throw e;
    var displayMessage = "Sys.ArgumentOutOfRangeException: " + (message ? message : Sys.Res.argumentOutOfRange);
    if (paramName) {
        displayMessage += "\n" + String.format(Sys.Res.paramName, paramName);
    }
    if (typeof(actualValue) !== "undefined" && actualValue !== null) {
        displayMessage += "\n" + String.format(Sys.Res.actualValue, actualValue);
    }
    var err = Error.create(displayMessage, {
        name: "Sys.ArgumentOutOfRangeException",
        paramName: paramName,
        actualValue: actualValue
    });
    err.popStackFrame();
    return err;
}
Error.argumentType = function Error$argumentType(paramName, actualType, expectedType, message) {
    /// <summary locid="M:J#Error.argumentType" />
    /// <param name="paramName" type="String" optional="true" mayBeNull="true"></param>
    /// <param name="actualType" type="Type" optional="true" mayBeNull="true"></param>
    /// <param name="expectedType" type="Type" optional="true" mayBeNull="true"></param>
    /// <param name="message" type="String" optional="true" mayBeNull="true"></param>
    /// <returns></returns>
    var e = Function._validateParams(arguments, [
        {name: "paramName", type: String, mayBeNull: true, optional: true},
        {name: "actualType", type: Type, mayBeNull: true, optional: true},
        {name: "expectedType", type: Type, mayBeNull: true, optional: true},
        {name: "message", type: String, mayBeNull: true, optional: true}
    ]);
    if (e) throw e;
    var displayMessage = "Sys.ArgumentTypeException: ";
    if (message) {
        displayMessage += message;
    }
    else if (actualType && expectedType) {
        displayMessage +=
            String.format(Sys.Res.argumentTypeWithTypes, actualType.getName(), expectedType.getName());
    }
    else {
        displayMessage += Sys.Res.argumentType;
    }
    if (paramName) {
        displayMessage += "\n" + String.format(Sys.Res.paramName, paramName);
    }
    var err = Error.create(displayMessage, {
        name: "Sys.ArgumentTypeException",
        paramName: paramName,
        actualType: actualType,
        expectedType: expectedType
    });
    err.popStackFrame();
    return err;
}
Error.argumentUndefined = function Error$argumentUndefined(paramName, message) {
    /// <summary locid="M:J#Error.argumentUndefined" />
    /// <param name="paramName" type="String" optional="true" mayBeNull="true"></param>
    /// <param name="message" type="String" optional="true" mayBeNull="true"></param>
    /// <returns></returns>
    var e = Function._validateParams(arguments, [
        {name: "paramName", type: String, mayBeNull: true, optional: true},
        {name: "message", type: String, mayBeNull: true, optional: true}
    ]);
    if (e) throw e;
    var displayMessage = "Sys.ArgumentUndefinedException: " + (message ? message : Sys.Res.argumentUndefined);
    if (paramName) {
        displayMessage += "\n" + String.format(Sys.Res.paramName, paramName);
    }
    var err = Error.create(displayMessage, { name: "Sys.ArgumentUndefinedException", paramName: paramName });
    err.popStackFrame();
    return err;
}
Error.format = function Error$format(message) {
    /// <summary locid="M:J#Error.format" />
    /// <param name="message" type="String" optional="true" mayBeNull="true"></param>
    /// <returns></returns>
    var e = Function._validateParams(arguments, [
        {name: "message", type: String, mayBeNull: true, optional: true}
    ]);
    if (e) throw e;
    var displayMessage = "Sys.FormatException: " + (message ? message : Sys.Res.format);
    var err = Error.create(displayMessage, {name: 'Sys.FormatException'});
    err.popStackFrame();
    return err;
}
Error.invalidOperation = function Error$invalidOperation(message) {
    /// <summary locid="M:J#Error.invalidOperation" />
    /// <param name="message" type="String" optional="true" mayBeNull="true"></param>
    /// <returns></returns>
    var e = Function._validateParams(arguments, [
        {name: "message", type: String, mayBeNull: true, optional: true}
    ]);
    if (e) throw e;
    var displayMessage = "Sys.InvalidOperationException: " + (message ? message : Sys.Res.invalidOperation);
    var err = Error.create(displayMessage, {name: 'Sys.InvalidOperationException'});
    err.popStackFrame();
    return err;
}
Error.notImplemented = function Error$notImplemented(message) {
    /// <summary locid="M:J#Error.notImplemented" />
    /// <param name="message" type="String" optional="true" mayBeNull="true"></param>
    /// <returns></returns>
    var e = Function._validateParams(arguments, [
        {name: "message", type: String, mayBeNull: true, optional: true}
    ]);
    if (e) throw e;
    var displayMessage = "Sys.NotImplementedException: " + (message ? message : Sys.Res.notImplemented);
    var err = Error.create(displayMessage, {name: 'Sys.NotImplementedException'});
    err.popStackFrame();
    return err;
}
Error.parameterCount = function Error$parameterCount(message) {
    /// <summary locid="M:J#Error.parameterCount" />
    /// <param name="message" type="String" optional="true" mayBeNull="true"></param>
    /// <returns></returns>
    var e = Function._validateParams(arguments, [
        {name: "message", type: String, mayBeNull: true, optional: true}
    ]);
    if (e) throw e;
    var displayMessage = "Sys.ParameterCountException: " + (message ? message : Sys.Res.parameterCount);
    var err = Error.create(displayMessage, {name: 'Sys.ParameterCountException'});
    err.popStackFrame();
    return err;
}
Error.prototype.popStackFrame = function Error$popStackFrame() {
    /// <summary locid="M:J#checkParam" />
    if (arguments.length !== 0) throw Error.parameterCount();
    if (typeof(this.stack) === "undefined" || this.stack === null ||
        typeof(this.fileName) === "undefined" || this.fileName === null ||
        typeof(this.lineNumber) === "undefined" || this.lineNumber === null) {
        return;
    }
    var stackFrames = this.stack.split("\n");
    var currentFrame = stackFrames[0];
    var pattern = this.fileName + ":" + this.lineNumber;
    while(typeof(currentFrame) !== "undefined" &&
          currentFrame !== null &&
          currentFrame.indexOf(pattern) === -1) {
        stackFrames.shift();
        currentFrame = stackFrames[0];
    }
    var nextFrame = stackFrames[1];
    if (typeof(nextFrame) === "undefined" || nextFrame === null) {
        return;
    }
    var nextFrameParts = nextFrame.match(/@(.*):(\d+)$/);
    if (typeof(nextFrameParts) === "undefined" || nextFrameParts === null) {
        return;
    }
    this.fileName = nextFrameParts[1];
    this.lineNumber = parseInt(nextFrameParts[2]);
    stackFrames.shift();
    this.stack = stackFrames.join("\n");
}
 
Object.__typeName = 'Object';
Object.__class = true;
Object.getType = function Object$getType(instance) {
    /// <summary locid="M:J#Object.getType" />
    /// <param name="instance"></param>
    /// <returns type="Type"></returns>
    var e = Function._validateParams(arguments, [
        {name: "instance"}
    ]);
    if (e) throw e;
    var ctor = instance.constructor;
    if (!ctor || (typeof(ctor) !== "function") || !ctor.__typeName || (ctor.__typeName === 'Object')) {
        return Object;
    }
    return ctor;
}
Object.getTypeName = function Object$getTypeName(instance) {
    /// <summary locid="M:J#Object.getTypeName" />
    /// <param name="instance"></param>
    /// <returns type="String"></returns>
    var e = Function._validateParams(arguments, [
        {name: "instance"}
    ]);
    if (e) throw e;
    return Object.getType(instance).getName();
}
 
String.__typeName = 'String';
String.__class = true;
String.prototype.endsWith = function String$endsWith(suffix) {
    /// <summary locid="M:J#String.endsWith" />
    /// <param name="suffix" type="String"></param>
    /// <returns type="Boolean"></returns>
    var e = Function._validateParams(arguments, [
        {name: "suffix", type: String}
    ]);
    if (e) throw e;
    return (this.substr(this.length - suffix.length) === suffix);
}
String.prototype.startsWith = function String$startsWith(prefix) {
    /// <summary locid="M:J#String.startsWith" />
    /// <param name="prefix" type="String"></param>
    /// <returns type="Boolean"></returns>
    var e = Function._validateParams(arguments, [
        {name: "prefix", type: String}
    ]);
    if (e) throw e;
    return (this.substr(0, prefix.length) === prefix);
}
String.prototype.trim = function String$trim() {
    /// <summary locid="M:J#String.trim" />
    /// <returns type="String"></returns>
    if (arguments.length !== 0) throw Error.parameterCount();
    return this.replace(/^\s+|\s+$/g, '');
}
String.prototype.trimEnd = function String$trimEnd() {
    /// <summary locid="M:J#String.trimEnd" />
    /// <returns type="String"></returns>
    if (arguments.length !== 0) throw Error.parameterCount();
    return this.replace(/\s+$/, '');
}
String.prototype.trimStart = function String$trimStart() {
    /// <summary locid="M:J#String.trimStart" />
    /// <returns type="String"></returns>
    if (arguments.length !== 0) throw Error.parameterCount();
    return this.replace(/^\s+/, '');
}
String.format = function String$format(format, args) {
    /// <summary locid="M:J#String.format" />
    /// <param name="format" type="String"></param>
    /// <param name="args" parameterArray="true" mayBeNull="true"></param>
    /// <returns type="String"></returns>
    var e = Function._validateParams(arguments, [
        {name: "format", type: String},
        {name: "args", mayBeNull: true, parameterArray: true}
    ]);
    if (e) throw e;
    return String._toFormattedString(false, arguments);
}
String._toFormattedString = function String$_toFormattedString(useLocale, args) {
    var result = '';
    var format = args[0];
    for (var i=0;;) {
        var open = format.indexOf('{', i);
        var close = format.indexOf('}', i);
        if ((open < 0) && (close < 0)) {
            result += format.slice(i);
            break;
        }
        if ((close > 0) && ((close < open) || (open < 0))) {
            if (format.charAt(close + 1) !== '}') {
                throw Error.argument('format', Sys.Res.stringFormatBraceMismatch);
            }
            result += format.slice(i, close + 1);
            i = close + 2;
            continue;
        }
        result += format.slice(i, open);
        i = open + 1;
        if (format.charAt(i) === '{') {
            result += '{';
            i++;
            continue;
        }
        if (close < 0) throw Error.argument('format', Sys.Res.stringFormatBraceMismatch);
        var brace = format.substring(i, close);
        var colonIndex = brace.indexOf(':');
        var argNumber = parseInt((colonIndex < 0)? brace : brace.substring(0, colonIndex), 10) + 1;
        if (isNaN(argNumber)) throw Error.argument('format', Sys.Res.stringFormatInvalid);
        var argFormat = (colonIndex < 0)? '' : brace.substring(colonIndex + 1);
        var arg = args[argNumber];
        if (typeof(arg) === "undefined" || arg === null) {
            arg = '';
        }
        if (arg.toFormattedString) {
            result += arg.toFormattedString(argFormat);
        }
        else if (useLocale && arg.localeFormat) {
            result += arg.localeFormat(argFormat);
        }
        else if (arg.format) {
            result += arg.format(argFormat);
        }
        else
            result += arg.toString();
        i = close + 1;
    }
    return result;
}
 
Boolean.__typeName = 'Boolean';
Boolean.__class = true;
Boolean.parse = function Boolean$parse(value) {
    /// <summary locid="M:J#Boolean.parse" />
    /// <param name="value" type="String"></param>
    /// <returns type="Boolean"></returns>
    var e = Function._validateParams(arguments, [
        {name: "value", type: String}
    ], false);
    if (e) throw e;
    var v = value.trim().toLowerCase();
    if (v === 'false') return false;
    if (v === 'true') return true;
    throw Error.argumentOutOfRange('value', value, Sys.Res.boolTrueOrFalse);
}
 
Date.__typeName = 'Date';
Date.__class = true;
 
Number.__typeName = 'Number';
Number.__class = true;
 
RegExp.__typeName = 'RegExp';
RegExp.__class = true;
 
if (!window) this.window = this;
window.Type = Function;
Type.__fullyQualifiedIdentifierRegExp = new RegExp("^[^.0-9 \\s|,;:&*=+\\-()\\[\\]{}^%#@!~\\n\\r\\t\\f\\\\]([^ \\s|,;:&*=+\\-()\\[\\]{}^%#@!~\\n\\r\\t\\f\\\\]*[^. \\s|,;:&*=+\\-()\\[\\]{}^%#@!~\\n\\r\\t\\f\\\\])?$", "i");
Type.__identifierRegExp = new RegExp("^[^.0-9 \\s|,;:&*=+\\-()\\[\\]{}^%#@!~\\n\\r\\t\\f\\\\][^. \\s|,;:&*=+\\-()\\[\\]{}^%#@!~\\n\\r\\t\\f\\\\]*$", "i");
Type.prototype.callBaseMethod = function Type$callBaseMethod(instance, name, baseArguments) {
    /// <summary locid="M:J#Type.callBaseMethod" />
    /// <param name="instance"></param>
    /// <param name="name" type="String"></param>
    /// <param name="baseArguments" type="Array" optional="true" mayBeNull="true" elementMayBeNull="true"></param>
    /// <returns></returns>
    var e = Function._validateParams(arguments, [
        {name: "instance"},
        {name: "name", type: String},
        {name: "baseArguments", type: Array, mayBeNull: true, optional: true, elementMayBeNull: true}
    ]);
    if (e) throw e;
    var baseMethod = Sys._getBaseMethod(this, instance, name);
    if (!baseMethod) throw Error.invalidOperation(String.format(Sys.Res.methodNotFound, name));
    if (!baseArguments) {
        return baseMethod.apply(instance);
    }
    else {
        return baseMethod.apply(instance, baseArguments);
    }
}
Type.prototype.getBaseMethod = function Type$getBaseMethod(instance, name) {
    /// <summary locid="M:J#Type.getBaseMethod" />
    /// <param name="instance"></param>
    /// <param name="name" type="String"></param>
    /// <returns type="Function" mayBeNull="true"></returns>
    var e = Function._validateParams(arguments, [
        {name: "instance"},
        {name: "name", type: String}
    ]);
    if (e) throw e;
    return Sys._getBaseMethod(this, instance, name);
}
Type.prototype.getBaseType = function Type$getBaseType() {
    /// <summary locid="M:J#Type.getBaseType" />
    /// <returns type="Type" mayBeNull="true"></returns>
    if (arguments.length !== 0) throw Error.parameterCount();
    return (typeof(this.__baseType) === "undefined") ? null : this.__baseType;
}
Type.prototype.getInterfaces = function Type$getInterfaces() {
    /// <summary locid="M:J#Type.getInterfaces" />
    /// <returns type="Array" elementType="Type" mayBeNull="false" elementMayBeNull="false"></returns>
    if (arguments.length !== 0) throw Error.parameterCount();
    var result = [];
    var type = this;
    while(type) {
        var interfaces = type.__interfaces;
        if (interfaces) {
            for (var i = 0, l = interfaces.length; i < l; i++) {
                var interfaceType = interfaces[i];
                if (!Array.contains(result, interfaceType)) {
                    result[result.length] = interfaceType;
                }
            }
        }
        type = type.__baseType;
    }
    return result;
}
Type.prototype.getName = function Type$getName() {
    /// <summary locid="M:J#Type.getName" />
    /// <returns type="String"></returns>
    if (arguments.length !== 0) throw Error.parameterCount();
    return (typeof(this.__typeName) === "undefined") ? "" : this.__typeName;
}
Type.prototype.implementsInterface = function Type$implementsInterface(interfaceType) {
    /// <summary locid="M:J#Type.implementsInterface" />
    /// <param name="interfaceType" type="Type"></param>
    /// <returns type="Boolean"></returns>
    var e = Function._validateParams(arguments, [
        {name: "interfaceType", type: Type}
    ]);
    if (e) throw e;
    this.resolveInheritance();
    var interfaceName = interfaceType.getName();
    var cache = this.__interfaceCache;
    if (cache) {
        var cacheEntry = cache[interfaceName];
        if (typeof(cacheEntry) !== 'undefined') return cacheEntry;
    }
    else {
        cache = this.__interfaceCache = {};
    }
    var baseType = this;
    while (baseType) {
        var interfaces = baseType.__interfaces;
        if (interfaces) {
            if (Array.indexOf(interfaces, interfaceType) !== -1) {
                return cache[interfaceName] = true;
            }
        }
        baseType = baseType.__baseType;
    }
    return cache[interfaceName] = false;
}
Type.prototype.inheritsFrom = function Type$inheritsFrom(parentType) {
    /// <summary locid="M:J#Type.inheritsFrom" />
    /// <param name="parentType" type="Type"></param>
    /// <returns type="Boolean"></returns>
    var e = Function._validateParams(arguments, [
        {name: "parentType", type: Type}
    ]);
    if (e) throw e;
    this.resolveInheritance();
    var baseType = this.__baseType;
    while (baseType) {
        if (baseType === parentType) {
            return true;
        }
        baseType = baseType.__baseType;
    }
    return false;
}
Type.prototype.initializeBase = function Type$initializeBase(instance, baseArguments) {
    /// <summary locid="M:J#Type.initializeBase" />
    /// <param name="instance"></param>
    /// <param name="baseArguments" type="Array" optional="true" mayBeNull="true" elementMayBeNull="true"></param>
    /// <returns></returns>
    var e = Function._validateParams(arguments, [
        {name: "instance"},
        {name: "baseArguments", type: Array, mayBeNull: true, optional: true, elementMayBeNull: true}
    ]);
    if (e) throw e;
    if (!Sys._isInstanceOfType(this, instance)) throw Error.argumentType('instance', Object.getType(instance), this);
    this.resolveInheritance();
    if (this.__baseType) {
        if (!baseArguments) {
            this.__baseType.apply(instance);
        }
        else {
            this.__baseType.apply(instance, baseArguments);
        }
    }
    return instance;
}
Type.prototype.isImplementedBy = function Type$isImplementedBy(instance) {
    /// <summary locid="M:J#Type.isImplementedBy" />
    /// <param name="instance" mayBeNull="true"></param>
    /// <returns type="Boolean"></returns>
    var e = Function._validateParams(arguments, [
        {name: "instance", mayBeNull: true}
    ]);
    if (e) throw e;
    if (typeof(instance) === "undefined" || instance === null) return false;
    var instanceType = Object.getType(instance);
    return !!(instanceType.implementsInterface && instanceType.implementsInterface(this));
}
Type.prototype.isInstanceOfType = function Type$isInstanceOfType(instance) {
    /// <summary locid="M:J#Type.isInstanceOfType" />
    /// <param name="instance" mayBeNull="true"></param>
    /// <returns type="Boolean"></returns>
    var e = Function._validateParams(arguments, [
        {name: "instance", mayBeNull: true}
    ]);
    if (e) throw e;
    return Sys._isInstanceOfType(this, instance);
}
Type.prototype.registerClass = function Type$registerClass(typeName, baseType, interfaceTypes) {
    /// <summary locid="M:J#Type.registerClass" />
    /// <param name="typeName" type="String"></param>
    /// <param name="baseType" type="Type" optional="true" mayBeNull="true"></param>
    /// <param name="interfaceTypes" parameterArray="true" type="Type"></param>
    /// <returns type="Type"></returns>
    var e = Function._validateParams(arguments, [
        {name: "typeName", type: String},
        {name: "baseType", type: Type, mayBeNull: true, optional: true},
        {name: "interfaceTypes", type: Type, parameterArray: true}
    ]);
    if (e) throw e;
    if (!Type.__fullyQualifiedIdentifierRegExp.test(typeName)) throw Error.argument('typeName', Sys.Res.notATypeName);
    var parsedName;
    try {
        parsedName = eval(typeName);
    }
    catch(e) {
        throw Error.argument('typeName', Sys.Res.argumentTypeName);
    }
    if (parsedName !== this) throw Error.argument('typeName', Sys.Res.badTypeName);
    if (Sys.__registeredTypes[typeName]) throw Error.invalidOperation(String.format(Sys.Res.typeRegisteredTwice, typeName));
    if ((arguments.length > 1) && (typeof(baseType) === 'undefined')) throw Error.argumentUndefined('baseType');
    if (baseType && !baseType.__class) throw Error.argument('baseType', Sys.Res.baseNotAClass);
    this.prototype.constructor = this;
    this.__typeName = typeName;
    this.__class = true;
    if (baseType) {
        this.__baseType = baseType;
        this.__basePrototypePending = true;
    }
    Sys.__upperCaseTypes[typeName.toUpperCase()] = this;
    if (interfaceTypes) {
        this.__interfaces = [];
        this.resolveInheritance();
        for (var i = 2, l = arguments.length; i < l; i++) {
            var interfaceType = arguments[i];
            if (!interfaceType.__interface) throw Error.argument('interfaceTypes[' + (i - 2) + ']', Sys.Res.notAnInterface);
            for (var methodName in interfaceType.prototype) {
                var method = interfaceType.prototype[methodName];
                if (!this.prototype[methodName]) {
                    this.prototype[methodName] = method;
                }
            }
            this.__interfaces.push(interfaceType);
        }
    }
    Sys.__registeredTypes[typeName] = true;
    return this;
}
Type.prototype.registerInterface = function Type$registerInterface(typeName) {
    /// <summary locid="M:J#Type.registerInterface" />
    /// <param name="typeName" type="String"></param>
    /// <returns type="Type"></returns>
    var e = Function._validateParams(arguments, [
        {name: "typeName", type: String}
    ]);
    if (e) throw e;
    if (!Type.__fullyQualifiedIdentifierRegExp.test(typeName)) throw Error.argument('typeName', Sys.Res.notATypeName);
    var parsedName;
    try {
        parsedName = eval(typeName);
    }
    catch(e) {
        throw Error.argument('typeName', Sys.Res.argumentTypeName);
    }
    if (parsedName !== this) throw Error.argument('typeName', Sys.Res.badTypeName);
    if (Sys.__registeredTypes[typeName]) throw Error.invalidOperation(String.format(Sys.Res.typeRegisteredTwice, typeName));
    Sys.__upperCaseTypes[typeName.toUpperCase()] = this;
    this.prototype.constructor = this;
    this.__typeName = typeName;
    this.__interface = true;
    Sys.__registeredTypes[typeName] = true;
    return this;
}
Type.prototype.resolveInheritance = function Type$resolveInheritance() {
    /// <summary locid="M:J#Type.resolveInheritance" />
    if (arguments.length !== 0) throw Error.parameterCount();
    if (this.__basePrototypePending) {
        var baseType = this.__baseType;
        baseType.resolveInheritance();
        for (var memberName in baseType.prototype) {
            var memberValue = baseType.prototype[memberName];
            if (!this.prototype[memberName]) {
                this.prototype[memberName] = memberValue;
            }
        }
        delete this.__basePrototypePending;
    }
}
Type.getRootNamespaces = function Type$getRootNamespaces() {
    /// <summary locid="M:J#Type.getRootNamespaces" />
    /// <returns type="Array"></returns>
    if (arguments.length !== 0) throw Error.parameterCount();
    return Array.clone(Sys.__rootNamespaces);
}
Type.isClass = function Type$isClass(type) {
    /// <summary locid="M:J#Type.isClass" />
    /// <param name="type" mayBeNull="true"></param>
    /// <returns type="Boolean"></returns>
    var e = Function._validateParams(arguments, [
        {name: "type", mayBeNull: true}
    ]);
    if (e) throw e;
    if ((typeof(type) === 'undefined') || (type === null)) return false;
    return !!type.__class;
}
Type.isInterface = function Type$isInterface(type) {
    /// <summary locid="M:J#Type.isInterface" />
    /// <param name="type" mayBeNull="true"></param>
    /// <returns type="Boolean"></returns>
    var e = Function._validateParams(arguments, [
        {name: "type", mayBeNull: true}
    ]);
    if (e) throw e;
    if ((typeof(type) === 'undefined') || (type === null)) return false;
    return !!type.__interface;
}
Type.isNamespace = function Type$isNamespace(object) {
    /// <summary locid="M:J#Type.isNamespace" />
    /// <param name="object" mayBeNull="true"></param>
    /// <returns type="Boolean"></returns>
    var e = Function._validateParams(arguments, [
        {name: "object", mayBeNull: true}
    ]);
    if (e) throw e;
    if ((typeof(object) === 'undefined') || (object === null)) return false;
    return !!object.__namespace;
}
Type.parse = function Type$parse(typeName, ns) {
    /// <summary locid="M:J#Type.parse" />
    /// <param name="typeName" type="String" mayBeNull="true"></param>
    /// <param name="ns" optional="true" mayBeNull="true"></param>
    /// <returns type="Type" mayBeNull="true"></returns>
    var e = Function._validateParams(arguments, [
        {name: "typeName", type: String, mayBeNull: true},
        {name: "ns", mayBeNull: true, optional: true}
    ]);
    if (e) throw e;
    var fn;
    if (ns) {
        fn = Sys.__upperCaseTypes[ns.getName().toUpperCase() + '.' + typeName.toUpperCase()];
        return fn || null;
    }
    if (!typeName) return null;
    if (!Type.__htClasses) {
        Type.__htClasses = {};
    }
    fn = Type.__htClasses[typeName];
    if (!fn) {
        fn = eval(typeName);
        if (typeof(fn) !== 'function') throw Error.argument('typeName', Sys.Res.notATypeName);
        Type.__htClasses[typeName] = fn;
    }
    return fn;
}
Type.registerNamespace = function Type$registerNamespace(namespacePath) {
    /// <summary locid="M:J#Type.registerNamespace" />
    /// <param name="namespacePath" type="String"></param>
    var e = Function._validateParams(arguments, [
        {name: "namespacePath", type: String}
    ]);
    if (e) throw e;
    Type._registerNamespace(namespacePath);
}
Type._registerNamespace = function Type$_registerNamespace(namespacePath) {
    if (!Type.__fullyQualifiedIdentifierRegExp.test(namespacePath)) throw Error.argument('namespacePath', Sys.Res.invalidNameSpace);
    var rootObject = window;
    var namespaceParts = namespacePath.split('.');
    for (var i = 0; i < namespaceParts.length; i++) {
        var currentPart = namespaceParts[i];
        var ns = rootObject[currentPart];
        var nsType = typeof(ns);
        if ((nsType !== "undefined") && (ns !== null)) {
            if (nsType === "function") {
                throw Error.invalidOperation(String.format(Sys.Res.namespaceContainsClass, namespaceParts.splice(0, i + 1).join('.')));
            }
            if ((typeof(ns) !== "object") || (ns instanceof Array)) {
                throw Error.invalidOperation(String.format(Sys.Res.namespaceContainsNonObject, namespaceParts.splice(0, i + 1).join('.')));
            }
        }
        if (!ns) {
            ns = rootObject[currentPart] = {};
        }
        if (!ns.__namespace) {
            if ((i === 0) && (namespacePath !== "Sys")) {
                Sys.__rootNamespaces[Sys.__rootNamespaces.length] = ns;
            }
            ns.__namespace = true;
            ns.__typeName = namespaceParts.slice(0, i + 1).join('.');
            var parsedName;
            try {
                parsedName = eval(ns.__typeName);
            }
            catch(e) {
                parsedName = null;
            }
            if (parsedName !== ns) {
                delete rootObject[currentPart];
                throw Error.argument('namespacePath', Sys.Res.invalidNameSpace);
            }
            ns.getName = function ns$getName() {return this.__typeName;}
        }
        rootObject = ns;
    }
}
Type._checkDependency = function Type$_checkDependency(dependency, featureName) {
    var scripts = Type._registerScript._scripts, isDependent = (scripts ? (!!scripts[dependency]) : false);
    if ((typeof(featureName) !== 'undefined') && !isDependent) {
        throw Error.invalidOperation(String.format(Sys.Res.requiredScriptReferenceNotIncluded, 
        featureName, dependency));
    }
    return isDependent;
}
Type._registerScript = function Type$_registerScript(scriptName, dependencies) {
    var scripts = Type._registerScript._scripts;
    if (!scripts) {
        Type._registerScript._scripts = scripts = {};
    }
    if (scripts[scriptName]) {
        throw Error.invalidOperation(String.format(Sys.Res.scriptAlreadyLoaded, scriptName));
    }
    scripts[scriptName] = true;
    if (dependencies) {
        for (var i = 0, l = dependencies.length; i < l; i++) {
            var dependency = dependencies[i];
            if (!Type._checkDependency(dependency)) {
                throw Error.invalidOperation(String.format(Sys.Res.scriptDependencyNotFound, scriptName, dependency));
            }
        }
    }
}
Type._registerNamespace("Sys");
Sys.__upperCaseTypes = {};
Sys.__rootNamespaces = [Sys];
Sys.__registeredTypes = {};
Sys._isInstanceOfType = function Sys$_isInstanceOfType(type, instance) {
    if (typeof(instance) === "undefined" || instance === null) return false;
    if (instance instanceof type) return true;
    var instanceType = Object.getType(instance);
    return !!(instanceType === type) ||
           (instanceType.inheritsFrom && instanceType.inheritsFrom(type)) ||
           (instanceType.implementsInterface && instanceType.implementsInterface(type));
}
Sys._getBaseMethod = function Sys$_getBaseMethod(type, instance, name) {
    if (!Sys._isInstanceOfType(type, instance)) throw Error.argumentType('instance', Object.getType(instance), type);
    var baseType = type.getBaseType();
    if (baseType) {
        var baseMethod = baseType.prototype[name];
        return (baseMethod instanceof Function) ? baseMethod : null;
    }
    return null;
}
Sys._isDomElement = function Sys$_isDomElement(obj) {
    var val = false;
    if (typeof (obj.nodeType) !== 'number') {
        var doc = obj.ownerDocument || obj.document || obj;
        if (doc != obj) {
            var w = doc.defaultView || doc.parentWindow;
            val = (w != obj);
        }
        else {
            val = (typeof (doc.body) === 'undefined');
        }
    }
    return !val;
}
 
Array.__typeName = 'Array';
Array.__class = true;
Array.add = Array.enqueue = function Array$enqueue(array, item) {
    /// <summary locid="M:J#Array.enqueue" />
    /// <param name="array" type="Array" elementMayBeNull="true"></param>
    /// <param name="item" mayBeNull="true"></param>
    var e = Function._validateParams(arguments, [
        {name: "array", type: Array, elementMayBeNull: true},
        {name: "item", mayBeNull: true}
    ]);
    if (e) throw e;
    array[array.length] = item;
}
Array.addRange = function Array$addRange(array, items) {
    /// <summary locid="M:J#Array.addRange" />
    /// <param name="array" type="Array" elementMayBeNull="true"></param>
    /// <param name="items" type="Array" elementMayBeNull="true"></param>
    var e = Function._validateParams(arguments, [
        {name: "array", type: Array, elementMayBeNull: true},
        {name: "items", type: Array, elementMayBeNull: true}
    ]);
    if (e) throw e;
    array.push.apply(array, items);
}
Array.clear = function Array$clear(array) {
    /// <summary locid="M:J#Array.clear" />
    /// <param name="array" type="Array" elementMayBeNull="true"></param>
    var e = Function._validateParams(arguments, [
        {name: "array", type: Array, elementMayBeNull: true}
    ]);
    if (e) throw e;
    array.length = 0;
}
Array.clone = function Array$clone(array) {
    /// <summary locid="M:J#Array.clone" />
    /// <param name="array" type="Array" elementMayBeNull="true"></param>
    /// <returns type="Array" elementMayBeNull="true"></returns>
    var e = Function._validateParams(arguments, [
        {name: "array", type: Array, elementMayBeNull: true}
    ]);
    if (e) throw e;
    if (array.length === 1) {
        return [array[0]];
    }
    else {
        return Array.apply(null, array);
    }
}
Array.contains = function Array$contains(array, item) {
    /// <summary locid="M:J#Array.contains" />
    /// <param name="array" type="Array" elementMayBeNull="true"></param>
    /// <param name="item" mayBeNull="true"></param>
    /// <returns type="Boolean"></returns>
    var e = Function._validateParams(arguments, [
        {name: "array", type: Array, elementMayBeNull: true},
        {name: "item", mayBeNull: true}
    ]);
    if (e) throw e;
    return (Sys._indexOf(array, item) >= 0);
}
Array.dequeue = function Array$dequeue(array) {
    /// <summary locid="M:J#Array.dequeue" />
    /// <param name="array" type="Array" elementMayBeNull="true"></param>
    /// <returns mayBeNull="true"></returns>
    var e = Function._validateParams(arguments, [
        {name: "array", type: Array, elementMayBeNull: true}
    ]);
    if (e) throw e;
    return array.shift();
}
Array.forEach = function Array$forEach(array, method, instance) {
    /// <summary locid="M:J#Array.forEach" />
    /// <param name="array" type="Array" elementMayBeNull="true"></param>
    /// <param name="method" type="Function"></param>
    /// <param name="instance" optional="true" mayBeNull="true"></param>
    var e = Function._validateParams(arguments, [
        {name: "array", type: Array, elementMayBeNull: true},
        {name: "method", type: Function},
        {name: "instance", mayBeNull: true, optional: true}
    ]);
    if (e) throw e;
    for (var i = 0, l = array.length; i < l; i++) {
        var elt = array[i];
        if (typeof(elt) !== 'undefined') method.call(instance, elt, i, array);
    }
}
Array.indexOf = function Array$indexOf(array, item, start) {
    /// <summary locid="M:J#Array.indexOf" />
    /// <param name="array" type="Array" elementMayBeNull="true"></param>
    /// <param name="item" optional="true" mayBeNull="true"></param>
    /// <param name="start" optional="true" mayBeNull="true"></param>
    /// <returns type="Number"></returns>
    var e = Function._validateParams(arguments, [
        {name: "array", type: Array, elementMayBeNull: true},
        {name: "item", mayBeNull: true, optional: true},
        {name: "start", mayBeNull: true, optional: true}
    ]);
    if (e) throw e;
    return Sys._indexOf(array, item, start);
}
Array.insert = function Array$insert(array, index, item) {
    /// <summary locid="M:J#Array.insert" />
    /// <param name="array" type="Array" elementMayBeNull="true"></param>
    /// <param name="index" mayBeNull="true"></param>
    /// <param name="item" mayBeNull="true"></param>
    var e = Function._validateParams(arguments, [
        {name: "array", type: Array, elementMayBeNull: true},
        {name: "index", mayBeNull: true},
        {name: "item", mayBeNull: true}
    ]);
    if (e) throw e;
    array.splice(index, 0, item);
}
Array.parse = function Array$parse(value) {
    /// <summary locid="M:J#Array.parse" />
    /// <param name="value" type="String" mayBeNull="true"></param>
    /// <returns type="Array" elementMayBeNull="true"></returns>
    var e = Function._validateParams(arguments, [
        {name: "value", type: String, mayBeNull: true}
    ]);
    if (e) throw e;
    if (!value) return [];
    var v = eval(value);
    if (!Array.isInstanceOfType(v)) throw Error.argument('value', Sys.Res.arrayParseBadFormat);
    return v;
}
Array.remove = function Array$remove(array, item) {
    /// <summary locid="M:J#Array.remove" />
    /// <param name="array" type="Array" elementMayBeNull="true"></param>
    /// <param name="item" mayBeNull="true"></param>
    /// <returns type="Boolean"></returns>
    var e = Function._validateParams(arguments, [
        {name: "array", type: Array, elementMayBeNull: true},
        {name: "item", mayBeNull: true}
    ]);
    if (e) throw e;
    var index = Sys._indexOf(array, item);
    if (index >= 0) {
        array.splice(index, 1);
    }
    return (index >= 0);
}
Array.removeAt = function Array$removeAt(array, index) {
    /// <summary locid="M:J#Array.removeAt" />
    /// <param name="array" type="Array" elementMayBeNull="true"></param>
    /// <param name="index" mayBeNull="true"></param>
    var e = Function._validateParams(arguments, [
        {name: "array", type: Array, elementMayBeNull: true},
        {name: "index", mayBeNull: true}
    ]);
    if (e) throw e;
    array.splice(index, 1);
}
Sys._indexOf = function Sys$_indexOf(array, item, start) {
    if (typeof(item) === "undefined") return -1;
    var length = array.length;
    if (length !== 0) {
        start = start - 0;
        if (isNaN(start)) {
            start = 0;
        }
        else {
            if (isFinite(start)) {
                start = start - (start % 1);
            }
            if (start < 0) {
                start = Math.max(0, length + start);
            }
        }
        for (var i = start; i < length; i++) {
            if ((typeof(array[i]) !== "undefined") && (array[i] === item)) {
                return i;
            }
        }
    }
    return -1;
}
Type._registerScript._scripts = {
	"MicrosoftAjaxCore.js": true,
	"MicrosoftAjaxGlobalization.js": true,
	"MicrosoftAjaxSerialization.js": true,
	"MicrosoftAjaxComponentModel.js": true,
	"MicrosoftAjaxHistory.js": true,
	"MicrosoftAjaxNetwork.js" : true,
	"MicrosoftAjaxWebServices.js": true };
 
Sys.IDisposable = function Sys$IDisposable() {
    throw Error.notImplemented();
}
    function Sys$IDisposable$dispose() {
        throw Error.notImplemented();
    }
Sys.IDisposable.prototype = {
    dispose: Sys$IDisposable$dispose
}
Sys.IDisposable.registerInterface('Sys.IDisposable');
 
Sys.StringBuilder = function Sys$StringBuilder(initialText) {
    /// <summary locid="M:J#Sys.StringBuilder.#ctor" />
    /// <param name="initialText" optional="true" mayBeNull="true"></param>
    var e = Function._validateParams(arguments, [
        {name: "initialText", mayBeNull: true, optional: true}
    ]);
    if (e) throw e;
    this._parts = (typeof(initialText) !== 'undefined' && initialText !== null && initialText !== '') ?
        [initialText.toString()] : [];
    this._value = {};
    this._len = 0;
}
    function Sys$StringBuilder$append(text) {
        /// <summary locid="M:J#Sys.StringBuilder.append" />
        /// <param name="text" mayBeNull="true"></param>
        var e = Function._validateParams(arguments, [
            {name: "text", mayBeNull: true}
        ]);
        if (e) throw e;
        this._parts[this._parts.length] = text;
    }
    function Sys$StringBuilder$appendLine(text) {
        /// <summary locid="M:J#Sys.StringBuilder.appendLine" />
        /// <param name="text" optional="true" mayBeNull="true"></param>
        var e = Function._validateParams(arguments, [
            {name: "text", mayBeNull: true, optional: true}
        ]);
        if (e) throw e;
        this._parts[this._parts.length] =
            ((typeof(text) === 'undefined') || (text === null) || (text === '')) ?
            '\r\n' : text + '\r\n';
    }
    function Sys$StringBuilder$clear() {
        /// <summary locid="M:J#Sys.StringBuilder.clear" />
        if (arguments.length !== 0) throw Error.parameterCount();
        this._parts = [];
        this._value = {};
        this._len = 0;
    }
    function Sys$StringBuilder$isEmpty() {
        /// <summary locid="M:J#Sys.StringBuilder.isEmpty" />
        /// <returns type="Boolean"></returns>
        if (arguments.length !== 0) throw Error.parameterCount();
        if (this._parts.length === 0) return true;
        return this.toString() === '';
    }
    function Sys$StringBuilder$toString(separator) {
        /// <summary locid="M:J#Sys.StringBuilder.toString" />
        /// <param name="separator" type="String" optional="true" mayBeNull="true"></param>
        /// <returns type="String"></returns>
        var e = Function._validateParams(arguments, [
            {name: "separator", type: String, mayBeNull: true, optional: true}
        ]);
        if (e) throw e;
        separator = separator || '';
        var parts = this._parts;
        if (this._len !== parts.length) {
            this._value = {};
            this._len = parts.length;
        }
        var val = this._value;
        if (typeof(val[separator]) === 'undefined') {
            if (separator !== '') {
                for (var i = 0; i < parts.length;) {
                    if ((typeof(parts[i]) === 'undefined') || (parts[i] === '') || (parts[i] === null)) {
                        parts.splice(i, 1);
                    }
                    else {
                        i++;
                    }
                }
            }
            val[separator] = this._parts.join(separator);
        }
        return val[separator];
    }
Sys.StringBuilder.prototype = {
    append: Sys$StringBuilder$append,
    appendLine: Sys$StringBuilder$appendLine,
    clear: Sys$StringBuilder$clear,
    isEmpty: Sys$StringBuilder$isEmpty,
    toString: Sys$StringBuilder$toString
}
Sys.StringBuilder.registerClass('Sys.StringBuilder');
 
Sys.Browser = {};
Sys.Browser.InternetExplorer = {};
Sys.Browser.Firefox = {};
Sys.Browser.Safari = {};
Sys.Browser.Opera = {};
Sys.Browser.agent = null;
Sys.Browser.hasDebuggerStatement = false;
Sys.Browser.name = navigator.appName;
Sys.Browser.version = parseFloat(navigator.appVersion);
Sys.Browser.documentMode = 0;
if (navigator.userAgent.indexOf(' MSIE ') > -1) {
    Sys.Browser.agent = Sys.Browser.InternetExplorer;
    Sys.Browser.version = parseFloat(navigator.userAgent.match(/MSIE (\d+\.\d+)/)[1]);
    if (Sys.Browser.version >= 8) {
        if (document.documentMode >= 7) {
            Sys.Browser.documentMode = document.documentMode;    
        }
    }
    Sys.Browser.hasDebuggerStatement = true;
}
else if (navigator.userAgent.indexOf(' Firefox/') > -1) {
    Sys.Browser.agent = Sys.Browser.Firefox;
    Sys.Browser.version = parseFloat(navigator.userAgent.match(/ Firefox\/(\d+\.\d+)/)[1]);
    Sys.Browser.name = 'Firefox';
    Sys.Browser.hasDebuggerStatement = true;
}
else if (navigator.userAgent.indexOf(' AppleWebKit/') > -1) {
    Sys.Browser.agent = Sys.Browser.Safari;
    Sys.Browser.version = parseFloat(navigator.userAgent.match(/ AppleWebKit\/(\d+(\.\d+)?)/)[1]);
    Sys.Browser.name = 'Safari';
}
else if (navigator.userAgent.indexOf('Opera/') > -1) {
    Sys.Browser.agent = Sys.Browser.Opera;
}
 
Sys.EventArgs = function Sys$EventArgs() {
    /// <summary locid="M:J#Sys.EventArgs.#ctor" />
    if (arguments.length !== 0) throw Error.parameterCount();
}
Sys.EventArgs.registerClass('Sys.EventArgs');
Sys.EventArgs.Empty = new Sys.EventArgs();
 
Sys.CancelEventArgs = function Sys$CancelEventArgs() {
    /// <summary locid="M:J#Sys.CancelEventArgs.#ctor" />
    if (arguments.length !== 0) throw Error.parameterCount();
    Sys.CancelEventArgs.initializeBase(this);
    this._cancel = false;
}
    function Sys$CancelEventArgs$get_cancel() {
        /// <value type="Boolean" locid="P:J#Sys.CancelEventArgs.cancel"></value>
        if (arguments.length !== 0) throw Error.parameterCount();
        return this._cancel;
    }
    function Sys$CancelEventArgs$set_cancel(value) {
        var e = Function._validateParams(arguments, [{name: "value", type: Boolean}]);
        if (e) throw e;
        this._cancel = value;
    }
Sys.CancelEventArgs.prototype = {
    get_cancel: Sys$CancelEventArgs$get_cancel,
    set_cancel: Sys$CancelEventArgs$set_cancel
}
Sys.CancelEventArgs.registerClass('Sys.CancelEventArgs', Sys.EventArgs);
Type.registerNamespace('Sys.UI');
 
Sys._Debug = function Sys$_Debug() {
    /// <summary locid="M:J#Sys.Debug.#ctor" />
    /// <field name="isDebug" type="Boolean" locid="F:J#Sys.Debug.isDebug"></field>
    if (arguments.length !== 0) throw Error.parameterCount();
}
    function Sys$_Debug$_appendConsole(text) {
        if ((typeof(Debug) !== 'undefined') && Debug.writeln) {
            Debug.writeln(text);
        }
        if (window.console && window.console.log) {
            window.console.log(text);
        }
        if (window.opera) {
            window.opera.postError(text);
        }
        if (window.debugService) {
            window.debugService.trace(text);
        }
    }
    function Sys$_Debug$_appendTrace(text) {
        var traceElement = document.getElementById('TraceConsole');
        if (traceElement && (traceElement.tagName.toUpperCase() === 'TEXTAREA')) {
            traceElement.value += text + '\n';
        }
    }
    function Sys$_Debug$assert(condition, message, displayCaller) {
        /// <summary locid="M:J#Sys.Debug.assert" />
        /// <param name="condition" type="Boolean"></param>
        /// <param name="message" type="String" optional="true" mayBeNull="true"></param>
        /// <param name="displayCaller" type="Boolean" optional="true"></param>
        var e = Function._validateParams(arguments, [
            {name: "condition", type: Boolean},
            {name: "message", type: String, mayBeNull: true, optional: true},
            {name: "displayCaller", type: Boolean, optional: true}
        ]);
        if (e) throw e;
        if (!condition) {
            message = (displayCaller && this.assert.caller) ?
                String.format(Sys.Res.assertFailedCaller, message, this.assert.caller) :
                String.format(Sys.Res.assertFailed, message);
            if (confirm(String.format(Sys.Res.breakIntoDebugger, message))) {
                this.fail(message);
            }
        }
    }
    function Sys$_Debug$clearTrace() {
        /// <summary locid="M:J#Sys.Debug.clearTrace" />
        if (arguments.length !== 0) throw Error.parameterCount();
        var traceElement = document.getElementById('TraceConsole');
        if (traceElement && (traceElement.tagName.toUpperCase() === 'TEXTAREA')) {
            traceElement.value = '';
        }
    }
    function Sys$_Debug$fail(message) {
        /// <summary locid="M:J#Sys.Debug.fail" />
        /// <param name="message" type="String" mayBeNull="true"></param>
        var e = Function._validateParams(arguments, [
            {name: "message", type: String, mayBeNull: true}
        ]);
        if (e) throw e;
        this._appendConsole(message);
        if (Sys.Browser.hasDebuggerStatement) {
            eval('debugger');
        }
    }
    function Sys$_Debug$trace(text) {
        /// <summary locid="M:J#Sys.Debug.trace" />
        /// <param name="text"></param>
        var e = Function._validateParams(arguments, [
            {name: "text"}
        ]);
        if (e) throw e;
        this._appendConsole(text);
        this._appendTrace(text);
    }
    function Sys$_Debug$traceDump(object, name) {
        /// <summary locid="M:J#Sys.Debug.traceDump" />
        /// <param name="object" mayBeNull="true"></param>
        /// <param name="name" type="String" mayBeNull="true" optional="true"></param>
        var e = Function._validateParams(arguments, [
            {name: "object", mayBeNull: true},
            {name: "name", type: String, mayBeNull: true, optional: true}
        ]);
        if (e) throw e;
        var text = this._traceDump(object, name, true);
    }
    function Sys$_Debug$_traceDump(object, name, recursive, indentationPadding, loopArray) {
        name = name? name : 'traceDump';
        indentationPadding = indentationPadding? indentationPadding : '';
        if (object === null) {
            this.trace(indentationPadding + name + ': null');
            return;
        }
        switch(typeof(object)) {
            case 'undefined':
                this.trace(indentationPadding + name + ': Undefined');
                break;
            case 'number': case 'string': case 'boolean':
                this.trace(indentationPadding + name + ': ' + object);
                break;
            default:
                if (Date.isInstanceOfType(object) || RegExp.isInstanceOfType(object)) {
                    this.trace(indentationPadding + name + ': ' + object.toString());
                    break;
                }
                if (!loopArray) {
                    loopArray = [];
                }
                else if (Array.contains(loopArray, object)) {
                    this.trace(indentationPadding + name + ': ...');
                    return;
                }
                Array.add(loopArray, object);
                if ((object == window) || (object === document) ||
                    (window.HTMLElement && (object instanceof HTMLElement)) ||
                    (typeof(object.nodeName) === 'string')) {
                    var tag = object.tagName? object.tagName : 'DomElement';
                    if (object.id) {
                        tag += ' - ' + object.id;
                    }
                    this.trace(indentationPadding + name + ' {' +  tag + '}');
                }
                else {
                    var typeName = Object.getTypeName(object);
                    this.trace(indentationPadding + name + (typeof(typeName) === 'string' ? ' {' + typeName + '}' : ''));
                    if ((indentationPadding === '') || recursive) {
                        indentationPadding += "    ";
                        var i, length, properties, p, v;
                        if (Array.isInstanceOfType(object)) {
                            length = object.length;
                            for (i = 0; i < length; i++) {
                                this._traceDump(object[i], '[' + i + ']', recursive, indentationPadding, loopArray);
                            }
                        }
                        else {
                            for (p in object) {
                                v = object[p];
                                if (!Function.isInstanceOfType(v)) {
                                    this._traceDump(v, p, recursive, indentationPadding, loopArray);
                                }
                            }
                        }
                    }
                }
                Array.remove(loopArray, object);
        }
    }
Sys._Debug.prototype = {
    _appendConsole: Sys$_Debug$_appendConsole,
    _appendTrace: Sys$_Debug$_appendTrace,
    assert: Sys$_Debug$assert,
    clearTrace: Sys$_Debug$clearTrace,
    fail: Sys$_Debug$fail,
    trace: Sys$_Debug$trace,
    traceDump: Sys$_Debug$traceDump,
    _traceDump: Sys$_Debug$_traceDump
}
Sys._Debug.registerClass('Sys._Debug');
Sys.Debug = new Sys._Debug();
    Sys.Debug.isDebug = true;
 
function Sys$Enum$parse(value, ignoreCase) {
    /// <summary locid="M:J#Sys.Enum.parse" />
    /// <param name="value" type="String"></param>
    /// <param name="ignoreCase" type="Boolean" optional="true"></param>
    /// <returns></returns>
    var e = Function._validateParams(arguments, [
        {name: "value", type: String},
        {name: "ignoreCase", type: Boolean, optional: true}
    ]);
    if (e) throw e;
    var values, parsed, val;
    if (ignoreCase) {
        values = this.__lowerCaseValues;
        if (!values) {
            this.__lowerCaseValues = values = {};
            var prototype = this.prototype;
            for (var name in prototype) {
                values[name.toLowerCase()] = prototype[name];
            }
        }
    }
    else {
        values = this.prototype;
    }
    if (!this.__flags) {
        val = (ignoreCase ? value.toLowerCase() : value);
        parsed = values[val.trim()];
        if (typeof(parsed) !== 'number') throw Error.argument('value', String.format(Sys.Res.enumInvalidValue, value, this.__typeName));
        return parsed;
    }
    else {
        var parts = (ignoreCase ? value.toLowerCase() : value).split(',');
        var v = 0;
        for (var i = parts.length - 1; i >= 0; i--) {
            var part = parts[i].trim();
            parsed = values[part];
            if (typeof(parsed) !== 'number') throw Error.argument('value', String.format(Sys.Res.enumInvalidValue, value.split(',')[i].trim(), this.__typeName));
            v |= parsed;
        }
        return v;
    }
}
function Sys$Enum$toString(value) {
    /// <summary locid="M:J#Sys.Enum.toString" />
    /// <param name="value" optional="true" mayBeNull="true"></param>
    /// <returns type="String"></returns>
    var e = Function._validateParams(arguments, [
        {name: "value", mayBeNull: true, optional: true}
    ]);
    if (e) throw e;
    if ((typeof(value) === 'undefined') || (value === null)) return this.__string;
    if ((typeof(value) != 'number') || ((value % 1) !== 0)) throw Error.argumentType('value', Object.getType(value), this);
    var values = this.prototype;
    var i;
    if (!this.__flags || (value === 0)) {
        for (i in values) {
            if (values[i] === value) {
                return i;
            }
        }
    }
    else {
        var sorted = this.__sortedValues;
        if (!sorted) {
            sorted = [];
            for (i in values) {
                sorted[sorted.length] = {key: i, value: values[i]};
            }
            sorted.sort(function(a, b) {
                return a.value - b.value;
            });
            this.__sortedValues = sorted;
        }
        var parts = [];
        var v = value;
        for (i = sorted.length - 1; i >= 0; i--) {
            var kvp = sorted[i];
            var vali = kvp.value;
            if (vali === 0) continue;
            if ((vali & value) === vali) {
                parts[parts.length] = kvp.key;
                v -= vali;
                if (v === 0) break;
            }
        }
        if (parts.length && v === 0) return parts.reverse().join(', ');
    }
    throw Error.argumentOutOfRange('value', value, String.format(Sys.Res.enumInvalidValue, value, this.__typeName));
}
Type.prototype.registerEnum = function Type$registerEnum(name, flags) {
    /// <summary locid="M:J#Sys.UI.LineType.#ctor" />
    /// <param name="name" type="String"></param>
    /// <param name="flags" type="Boolean" optional="true"></param>
    var e = Function._validateParams(arguments, [
        {name: "name", type: String},
        {name: "flags", type: Boolean, optional: true}
    ]);
    if (e) throw e;
    if (!Type.__fullyQualifiedIdentifierRegExp.test(name)) throw Error.argument('name', Sys.Res.notATypeName);
    var parsedName;
    try {
        parsedName = eval(name);
    }
    catch(e) {
        throw Error.argument('name', Sys.Res.argumentTypeName);
    }
    if (parsedName !== this) throw Error.argument('name', Sys.Res.badTypeName);
    if (Sys.__registeredTypes[name]) throw Error.invalidOperation(String.format(Sys.Res.typeRegisteredTwice, name));
    for (var j in this.prototype) {
        var val = this.prototype[j];
        if (!Type.__identifierRegExp.test(j)) throw Error.invalidOperation(String.format(Sys.Res.enumInvalidValueName, j));
        if (typeof(val) !== 'number' || (val % 1) !== 0) throw Error.invalidOperation(Sys.Res.enumValueNotInteger);
        if (typeof(this[j]) !== 'undefined') throw Error.invalidOperation(String.format(Sys.Res.enumReservedName, j));
    }
    Sys.__upperCaseTypes[name.toUpperCase()] = this;
    for (var i in this.prototype) {
        this[i] = this.prototype[i];
    }
    this.__typeName = name;
    this.parse = Sys$Enum$parse;
    this.__string = this.toString();
    this.toString = Sys$Enum$toString;
    this.__flags = flags;
    this.__enum = true;
    Sys.__registeredTypes[name] = true;
}
Type.isEnum = function Type$isEnum(type) {
    /// <summary locid="M:J#Type.isEnum" />
    /// <param name="type" mayBeNull="true"></param>
    /// <returns type="Boolean"></returns>
    var e = Function._validateParams(arguments, [
        {name: "type", mayBeNull: true}
    ]);
    if (e) throw e;
    if ((typeof(type) === 'undefined') || (type === null)) return false;
    return !!type.__enum;
}
Type.isFlags = function Type$isFlags(type) {
    /// <summary locid="M:J#Type.isFlags" />
    /// <param name="type" mayBeNull="true"></param>
    /// <returns type="Boolean"></returns>
    var e = Function._validateParams(arguments, [
        {name: "type", mayBeNull: true}
    ]);
    if (e) throw e;
    if ((typeof(type) === 'undefined') || (type === null)) return false;
    return !!type.__flags;
}
Sys.CollectionChange = function Sys$CollectionChange(action, newItems, newStartingIndex, oldItems, oldStartingIndex) {
    /// <summary locid="M:J#Sys.CollectionChange.#ctor" />
    /// <param name="action" type="Sys.NotifyCollectionChangedAction"></param>
    /// <param name="newItems" optional="true" mayBeNull="true"></param>
    /// <param name="newStartingIndex" type="Number" integer="true" optional="true" mayBeNull="true"></param>
    /// <param name="oldItems" optional="true" mayBeNull="true"></param>
    /// <param name="oldStartingIndex" type="Number" integer="true" optional="true" mayBeNull="true"></param>
    /// <field name="action" type="Sys.NotifyCollectionChangedAction" locid="F:J#Sys.CollectionChange.action"></field>
    /// <field name="newItems" type="Array" mayBeNull="true" elementMayBeNull="true" locid="F:J#Sys.CollectionChange.newItems"></field>
    /// <field name="newStartingIndex" type="Number" integer="true" locid="F:J#Sys.CollectionChange.newStartingIndex"></field>
    /// <field name="oldItems" type="Array" mayBeNull="true" elementMayBeNull="true" locid="F:J#Sys.CollectionChange.oldItems"></field>
    /// <field name="oldStartingIndex" type="Number" integer="true" locid="F:J#Sys.CollectionChange.oldStartingIndex"></field>
    var e = Function._validateParams(arguments, [
        {name: "action", type: Sys.NotifyCollectionChangedAction},
        {name: "newItems", mayBeNull: true, optional: true},
        {name: "newStartingIndex", type: Number, mayBeNull: true, integer: true, optional: true},
        {name: "oldItems", mayBeNull: true, optional: true},
        {name: "oldStartingIndex", type: Number, mayBeNull: true, integer: true, optional: true}
    ]);
    if (e) throw e;
    this.action = action;
    if (newItems) {
        if (!(newItems instanceof Array)) {
            newItems = [newItems];
        }
    }
    this.newItems = newItems || null;
    if (typeof newStartingIndex !== "number") {
        newStartingIndex = -1;
    }
    this.newStartingIndex = newStartingIndex;
    if (oldItems) {
        if (!(oldItems instanceof Array)) {
            oldItems = [oldItems];
        }
    }
    this.oldItems = oldItems || null;
    if (typeof oldStartingIndex !== "number") {
        oldStartingIndex = -1;
    }
    this.oldStartingIndex = oldStartingIndex;
}
Sys.CollectionChange.registerClass("Sys.CollectionChange");
Sys.NotifyCollectionChangedAction = function Sys$NotifyCollectionChangedAction() {
    /// <summary locid="M:J#Sys.NotifyCollectionChangedAction.#ctor" />
    /// <field name="add" type="Number" integer="true" static="true" locid="F:J#Sys.NotifyCollectionChangedAction.add"></field>
    /// <field name="remove" type="Number" integer="true" static="true" locid="F:J#Sys.NotifyCollectionChangedAction.remove"></field>
    /// <field name="reset" type="Number" integer="true" static="true" locid="F:J#Sys.NotifyCollectionChangedAction.reset"></field>
    if (arguments.length !== 0) throw Error.parameterCount();
    throw Error.notImplemented();
}
Sys.NotifyCollectionChangedAction.prototype = {
    add: 0,
    remove: 1,
    reset: 2
}
Sys.NotifyCollectionChangedAction.registerEnum('Sys.NotifyCollectionChangedAction');
Sys.NotifyCollectionChangedEventArgs = function Sys$NotifyCollectionChangedEventArgs(changes) {
    /// <summary locid="M:J#Sys.NotifyCollectionChangedEventArgs.#ctor" />
    /// <param name="changes" type="Array" elementType="Sys.CollectionChange"></param>
    var e = Function._validateParams(arguments, [
        {name: "changes", type: Array, elementType: Sys.CollectionChange}
    ]);
    if (e) throw e;
    this._changes = changes;
    Sys.NotifyCollectionChangedEventArgs.initializeBase(this);
}
    function Sys$NotifyCollectionChangedEventArgs$get_changes() {
        /// <value type="Array" elementType="Sys.CollectionChange" locid="P:J#Sys.NotifyCollectionChangedEventArgs.changes"></value>
        if (arguments.length !== 0) throw Error.parameterCount();
        return this._changes || [];
    }
Sys.NotifyCollectionChangedEventArgs.prototype = {
    get_changes: Sys$NotifyCollectionChangedEventArgs$get_changes
}
Sys.NotifyCollectionChangedEventArgs.registerClass("Sys.NotifyCollectionChangedEventArgs", Sys.EventArgs);
Sys.Observer = function Sys$Observer() {
    throw Error.invalidOperation();
}
Sys.Observer.registerClass("Sys.Observer");
Sys.Observer.makeObservable = function Sys$Observer$makeObservable(target) {
    /// <summary locid="M:J#Sys.Observer.makeObservable" />
    /// <param name="target" mayBeNull="false"></param>
    /// <returns></returns>
    var e = Function._validateParams(arguments, [
        {name: "target"}
    ]);
    if (e) throw e;
    var isArray = target instanceof Array,
        o = Sys.Observer;
    Sys.Observer._ensureObservable(target);
    if (target.setValue === o._observeMethods.setValue) return target;
    o._addMethods(target, o._observeMethods);
    if (isArray) {
        o._addMethods(target, o._arrayMethods);
    }
    return target;
}
Sys.Observer._ensureObservable = function Sys$Observer$_ensureObservable(target) {
    var type = typeof target;
    if ((type === "string") || (type === "number") || (type === "boolean") || (type === "date")) {
        throw Error.invalidOperation(String.format(Sys.Res.notObservable, type));
    }
}
Sys.Observer._addMethods = function Sys$Observer$_addMethods(target, methods) {
    for (var m in methods) {
        if (target[m] && (target[m] !== methods[m])) {
            throw Error.invalidOperation(String.format(Sys.Res.observableConflict, m));
        }
        target[m] = methods[m];
    }
}
Sys.Observer._addEventHandler = function Sys$Observer$_addEventHandler(target, eventName, handler) {
    Sys.Observer._getContext(target, true).events._addHandler(eventName, handler);
}
Sys.Observer.addEventHandler = function Sys$Observer$addEventHandler(target, eventName, handler) {
    /// <summary locid="M:J#Sys.Observer.addEventHandler" />
    /// <param name="target"></param>
    /// <param name="eventName" type="String"></param>
    /// <param name="handler" type="Function"></param>
    var e = Function._validateParams(arguments, [
        {name: "target"},
        {name: "eventName", type: String},
        {name: "handler", type: Function}
    ]);
    if (e) throw e;
    Sys.Observer._ensureObservable(target);
    Sys.Observer._addEventHandler(target, eventName, handler);
}
Sys.Observer._removeEventHandler = function Sys$Observer$_removeEventHandler(target, eventName, handler) {
    Sys.Observer._getContext(target, true).events._removeHandler(eventName, handler);
}
Sys.Observer.removeEventHandler = function Sys$Observer$removeEventHandler(target, eventName, handler) {
    /// <summary locid="M:J#Sys.Observer.removeEventHandler" />
    /// <param name="target"></param>
    /// <param name="eventName" type="String"></param>
    /// <param name="handler" type="Function"></param>
    var e = Function._validateParams(arguments, [
        {name: "target"},
        {name: "eventName", type: String},
        {name: "handler", type: Function}
    ]);
    if (e) throw e;
    Sys.Observer._ensureObservable(target);
    Sys.Observer._removeEventHandler(target, eventName, handler);
}
Sys.Observer.raiseEvent = function Sys$Observer$raiseEvent(target, eventName, eventArgs) {
    /// <summary locid="M:J#Sys.Observer.raiseEvent" />
    /// <param name="target"></param>
    /// <param name="eventName" type="String"></param>
    /// <param name="eventArgs" type="Sys.EventArgs"></param>
    var e = Function._validateParams(arguments, [
        {name: "target"},
        {name: "eventName", type: String},
        {name: "eventArgs", type: Sys.EventArgs}
    ]);
    if (e) throw e;
    Sys.Observer._ensureObservable(target);
    var ctx = Sys.Observer._getContext(target);
    if (!ctx) return;
    var handler = ctx.events.getHandler(eventName);
    if (handler) {
        handler(target, eventArgs);
    }
}
Sys.Observer.addPropertyChanged = function Sys$Observer$addPropertyChanged(target, handler) {
    /// <summary locid="M:J#Sys.Observer.addPropertyChanged" />
    /// <param name="target" mayBeNull="false"></param>
    /// <param name="handler" type="Function"></param>
    var e = Function._validateParams(arguments, [
        {name: "target"},
        {name: "handler", type: Function}
    ]);
    if (e) throw e;
    Sys.Observer._ensureObservable(target);
    Sys.Observer._addEventHandler(target, "propertyChanged", handler);
}
Sys.Observer.removePropertyChanged = function Sys$Observer$removePropertyChanged(target, handler) {
    /// <summary locid="M:J#Sys.Observer.removePropertyChanged" />
    /// <param name="target" mayBeNull="false"></param>
    /// <param name="handler" type="Function"></param>
    var e = Function._validateParams(arguments, [
        {name: "target"},
        {name: "handler", type: Function}
    ]);
    if (e) throw e;
    Sys.Observer._ensureObservable(target);
    Sys.Observer._removeEventHandler(target, "propertyChanged", handler);
}
Sys.Observer.beginUpdate = function Sys$Observer$beginUpdate(target) {
    /// <summary locid="M:J#Sys.Observer.beginUpdate" />
    /// <param name="target" mayBeNull="false"></param>
    var e = Function._validateParams(arguments, [
        {name: "target"}
    ]);
    if (e) throw e;
    Sys.Observer._ensureObservable(target);
    Sys.Observer._getContext(target, true).updating = true;
}
Sys.Observer.endUpdate = function Sys$Observer$endUpdate(target) {
    /// <summary locid="M:J#Sys.Observer.endUpdate" />
    /// <param name="target" mayBeNull="false"></param>
    var e = Function._validateParams(arguments, [
        {name: "target"}
    ]);
    if (e) throw e;
    Sys.Observer._ensureObservable(target);
    var ctx = Sys.Observer._getContext(target);
    if (!ctx || !ctx.updating) return;
    ctx.updating = false;
    var dirty = ctx.dirty;
    ctx.dirty = false;
    if (dirty) {
        if (target instanceof Array) {
            var changes = ctx.changes;
            ctx.changes = null;
            Sys.Observer.raiseCollectionChanged(target, changes);
        }
        Sys.Observer.raisePropertyChanged(target, "");
    }
}
Sys.Observer.isUpdating = function Sys$Observer$isUpdating(target) {
    /// <summary locid="M:J#Sys.Observer.isUpdating" />
    /// <param name="target" mayBeNull="false"></param>
    /// <returns type="Boolean"></returns>
    var e = Function._validateParams(arguments, [
        {name: "target"}
    ]);
    if (e) throw e;
    Sys.Observer._ensureObservable(target);
    var ctx = Sys.Observer._getContext(target);
    return ctx ? ctx.updating : false;
}
Sys.Observer._setValue = function Sys$Observer$_setValue(target, propertyName, value) {
    var getter, setter, mainTarget = target, path = propertyName.split('.');
    for (var i = 0, l = (path.length - 1); i < l ; i++) {
        var name = path[i];
        getter = target["get_" + name]; 
        if (typeof (getter) === "function") {
            target = getter.call(target);
        }
        else {
            target = target[name];
        }
        var type = typeof (target);
        if ((target === null) || (type === "undefined")) {
            throw Error.invalidOperation(String.format(Sys.Res.nullReferenceInPath, propertyName));
        }
    }    
    var currentValue, lastPath = path[l];
    getter = target["get_" + lastPath];
    setter = target["set_" + lastPath];
    if (typeof(getter) === 'function') {
        currentValue = getter.call(target);
    }
    else {
        currentValue = target[lastPath];
    }
    if (typeof(setter) === 'function') {
        setter.call(target, value);
    }
    else {
        target[lastPath] = value;
    }
    if (currentValue !== value) {
        var ctx = Sys.Observer._getContext(mainTarget);
        if (ctx && ctx.updating) {
            ctx.dirty = true;
            return;
        };
        Sys.Observer.raisePropertyChanged(mainTarget, path[0]);
    }
}
Sys.Observer.setValue = function Sys$Observer$setValue(target, propertyName, value) {
    /// <summary locid="M:J#Sys.Observer.setValue" />
    /// <param name="target" mayBeNull="false"></param>
    /// <param name="propertyName" type="String"></param>
    /// <param name="value" mayBeNull="true"></param>
    var e = Function._validateParams(arguments, [
        {name: "target"},
        {name: "propertyName", type: String},
        {name: "value", mayBeNull: true}
    ]);
    if (e) throw e;
    Sys.Observer._ensureObservable(target);
    Sys.Observer._setValue(target, propertyName, value);
}
Sys.Observer.raisePropertyChanged = function Sys$Observer$raisePropertyChanged(target, propertyName) {
    /// <summary locid="M:J#Sys.Observer.raisePropertyChanged" />
    /// <param name="target" mayBeNull="false"></param>
    /// <param name="propertyName" type="String"></param>
    Sys.Observer.raiseEvent(target, "propertyChanged", new Sys.PropertyChangedEventArgs(propertyName));
}
Sys.Observer.addCollectionChanged = function Sys$Observer$addCollectionChanged(target, handler) {
    /// <summary locid="M:J#Sys.Observer.addCollectionChanged" />
    /// <param name="target" type="Array" elementMayBeNull="true"></param>
    /// <param name="handler" type="Function"></param>
    var e = Function._validateParams(arguments, [
        {name: "target", type: Array, elementMayBeNull: true},
        {name: "handler", type: Function}
    ]);
    if (e) throw e;
    Sys.Observer._addEventHandler(target, "collectionChanged", handler);
}
Sys.Observer.removeCollectionChanged = function Sys$Observer$removeCollectionChanged(target, handler) {
    /// <summary locid="M:J#Sys.Observer.removeCollectionChanged" />
    /// <param name="target" type="Array" elementMayBeNull="true"></param>
    /// <param name="handler" type="Function"></param>
    var e = Function._validateParams(arguments, [
        {name: "target", type: Array, elementMayBeNull: true},
        {name: "handler", type: Function}
    ]);
    if (e) throw e;
    Sys.Observer._removeEventHandler(target, "collectionChanged", handler);
}
Sys.Observer._collectionChange = function Sys$Observer$_collectionChange(target, change) {
    var ctx = Sys.Observer._getContext(target);
    if (ctx && ctx.updating) {
        ctx.dirty = true;
        var changes = ctx.changes;
        if (!changes) {
            ctx.changes = changes = [change];
        }
        else {
            changes.push(change);
        }
    }
    else {
        Sys.Observer.raiseCollectionChanged(target, [change]);
        Sys.Observer.raisePropertyChanged(target, 'length');
    }
}
Sys.Observer.add = function Sys$Observer$add(target, item) {
    /// <summary locid="M:J#Sys.Observer.add" />
    /// <param name="target" type="Array" elementMayBeNull="true"></param>
    /// <param name="item" mayBeNull="true"></param>
    var e = Function._validateParams(arguments, [
        {name: "target", type: Array, elementMayBeNull: true},
        {name: "item", mayBeNull: true}
    ]);
    if (e) throw e;
    var change = new Sys.CollectionChange(Sys.NotifyCollectionChangedAction.add, [item], target.length);
    Array.add(target, item);
    Sys.Observer._collectionChange(target, change);
}
Sys.Observer.addRange = function Sys$Observer$addRange(target, items) {
    /// <summary locid="M:J#Sys.Observer.addRange" />
    /// <param name="target" type="Array" elementMayBeNull="true"></param>
    /// <param name="items" type="Array" elementMayBeNull="true"></param>
    var e = Function._validateParams(arguments, [
        {name: "target", type: Array, elementMayBeNull: true},
        {name: "items", type: Array, elementMayBeNull: true}
    ]);
    if (e) throw e;
    var change = new Sys.CollectionChange(Sys.NotifyCollectionChangedAction.add, items, target.length);
    Array.addRange(target, items);
    Sys.Observer._collectionChange(target, change);
}
Sys.Observer.clear = function Sys$Observer$clear(target) {
    /// <summary locid="M:J#Sys.Observer.clear" />
    /// <param name="target" type="Array" elementMayBeNull="true"></param>
    var e = Function._validateParams(arguments, [
        {name: "target", type: Array, elementMayBeNull: true}
    ]);
    if (e) throw e;
    var oldItems = Array.clone(target);
    Array.clear(target);
    Sys.Observer._collectionChange(target, new Sys.CollectionChange(Sys.NotifyCollectionChangedAction.reset, null, -1, oldItems, 0));
}
Sys.Observer.insert = function Sys$Observer$insert(target, index, item) {
    /// <summary locid="M:J#Sys.Observer.insert" />
    /// <param name="target" type="Array" elementMayBeNull="true"></param>
    /// <param name="index" type="Number" integer="true"></param>
    /// <param name="item" mayBeNull="true"></param>
    var e = Function._validateParams(arguments, [
        {name: "target", type: Array, elementMayBeNull: true},
        {name: "index", type: Number, integer: true},
        {name: "item", mayBeNull: true}
    ]);
    if (e) throw e;
    Array.insert(target, index, item);
    Sys.Observer._collectionChange(target, new Sys.CollectionChange(Sys.NotifyCollectionChangedAction.add, [item], index));
}
Sys.Observer.remove = function Sys$Observer$remove(target, item) {
    /// <summary locid="M:J#Sys.Observer.remove" />
    /// <param name="target" type="Array" elementMayBeNull="true"></param>
    /// <param name="item" mayBeNull="true"></param>
    /// <returns type="Boolean"></returns>
    var e = Function._validateParams(arguments, [
        {name: "target", type: Array, elementMayBeNull: true},
        {name: "item", mayBeNull: true}
    ]);
    if (e) throw e;
    var index = Array.indexOf(target, item);
    if (index !== -1) {
        Array.remove(target, item);
        Sys.Observer._collectionChange(target, new Sys.CollectionChange(Sys.NotifyCollectionChangedAction.remove, null, -1, [item], index));
        return true;
    }
    return false;
}
Sys.Observer.removeAt = function Sys$Observer$removeAt(target, index) {
    /// <summary locid="M:J#Sys.Observer.removeAt" />
    /// <param name="target" type="Array" elementMayBeNull="true"></param>
    /// <param name="index" type="Number" integer="true"></param>
    var e = Function._validateParams(arguments, [
        {name: "target", type: Array, elementMayBeNull: true},
        {name: "index", type: Number, integer: true}
    ]);
    if (e) throw e;
    if ((index > -1) && (index < target.length)) {
        var item = target[index];
        Array.removeAt(target, index);
        Sys.Observer._collectionChange(target, new Sys.CollectionChange(Sys.NotifyCollectionChangedAction.remove, null, -1, [item], index));
    }
}
Sys.Observer.raiseCollectionChanged = function Sys$Observer$raiseCollectionChanged(target, changes) {
    /// <summary locid="M:J#Sys.Observer.raiseCollectionChanged" />
    /// <param name="target"></param>
    /// <param name="changes" type="Array" elementType="Sys.CollectionChange"></param>
    Sys.Observer.raiseEvent(target, "collectionChanged", new Sys.NotifyCollectionChangedEventArgs(changes));
}
Sys.Observer._observeMethods = {
    add_propertyChanged: function(handler) {
        Sys.Observer._addEventHandler(this, "propertyChanged", handler);
    },
    remove_propertyChanged: function(handler) {
        Sys.Observer._removeEventHandler(this, "propertyChanged", handler);
    },
    addEventHandler: function(eventName, handler) {
        /// <summary locid="M:J#Sys.Observer.raiseCollectionChanged" />
        /// <param name="eventName" type="String"></param>
        /// <param name="handler" type="Function"></param>
        var e = Function._validateParams(arguments, [
            {name: "eventName", type: String},
            {name: "handler", type: Function}
        ]);
        if (e) throw e;
        Sys.Observer._addEventHandler(this, eventName, handler);
    },
    removeEventHandler: function(eventName, handler) {
        /// <summary locid="M:J#Sys.Observer.raiseCollectionChanged" />
        /// <param name="eventName" type="String"></param>
        /// <param name="handler" type="Function"></param>
        var e = Function._validateParams(arguments, [
            {name: "eventName", type: String},
            {name: "handler", type: Function}
        ]);
        if (e) throw e;
        Sys.Observer._removeEventHandler(this, eventName, handler);
    },
    get_isUpdating: function() {
        /// <summary locid="M:J#Sys.Observer.raiseCollectionChanged" />
        /// <returns type="Boolean"></returns>
        return Sys.Observer.isUpdating(this);
    },
    beginUpdate: function() {
        /// <summary locid="M:J#Sys.Observer.raiseCollectionChanged" />
        Sys.Observer.beginUpdate(this);
    },
    endUpdate: function() {
        /// <summary locid="M:J#Sys.Observer.raiseCollectionChanged" />
        Sys.Observer.endUpdate(this);
    },
    setValue: function(name, value) {
        /// <summary locid="M:J#Sys.Observer.raiseCollectionChanged" />
        /// <param name="name" type="String"></param>
        /// <param name="value" mayBeNull="true"></param>
        var e = Function._validateParams(arguments, [
            {name: "name", type: String},
            {name: "value", mayBeNull: true}
        ]);
        if (e) throw e;
        Sys.Observer._setValue(this, name, value);
    },
    raiseEvent: function(eventName, eventArgs) {
        /// <summary locid="M:J#Sys.Observer.raiseCollectionChanged" />
        /// <param name="eventName" type="String"></param>
        /// <param name="eventArgs" type="Sys.EventArgs"></param>
        Sys.Observer.raiseEvent(this, eventName, eventArgs);
    },
    raisePropertyChanged: function(name) {
        /// <summary locid="M:J#Sys.Observer.raiseCollectionChanged" />
        /// <param name="name" type="String"></param>
        Sys.Observer.raiseEvent(this, "propertyChanged", new Sys.PropertyChangedEventArgs(name));
    }
}
Sys.Observer._arrayMethods = {
    add_collectionChanged: function(handler) {
        Sys.Observer._addEventHandler(this, "collectionChanged", handler);
    },
    remove_collectionChanged: function(handler) {
        Sys.Observer._removeEventHandler(this, "collectionChanged", handler);
    },
    add: function(item) {
        /// <summary locid="M:J#Sys.Observer.raiseCollectionChanged" />
        /// <param name="item" mayBeNull="true"></param>
        Sys.Observer.add(this, item);
    },
    addRange: function(items) {
        /// <summary locid="M:J#Sys.Observer.raiseCollectionChanged" />
        /// <param name="items" type="Array" elementMayBeNull="true"></param>
        Sys.Observer.addRange(this, items);
    },
    clear: function() {
        /// <summary locid="M:J#Sys.Observer.raiseCollectionChanged" />
        Sys.Observer.clear(this);
    },
    insert: function(index, item) { 
        /// <summary locid="M:J#Sys.Observer.raiseCollectionChanged" />
        /// <param name="index" type="Number" integer="true"></param>
        /// <param name="item" mayBeNull="true"></param>
        Sys.Observer.insert(this, index, item);
    },
    remove: function(item) {
        /// <summary locid="M:J#Sys.Observer.raiseCollectionChanged" />
        /// <param name="item" mayBeNull="true"></param>
        /// <returns type="Boolean"></returns>
        return Sys.Observer.remove(this, item);
    },
    removeAt: function(index) {
        /// <summary locid="M:J#Sys.Observer.raiseCollectionChanged" />
        /// <param name="index" type="Number" integer="true"></param>
        Sys.Observer.removeAt(this, index);
    },
    raiseCollectionChanged: function(changes) {
        /// <summary locid="M:J#Sys.Observer.raiseCollectionChanged" />
        /// <param name="changes" type="Array" elementType="Sys.CollectionChange"></param>
        Sys.Observer.raiseEvent(this, "collectionChanged", new Sys.NotifyCollectionChangedEventArgs(changes));
    }
}
Sys.Observer._getContext = function Sys$Observer$_getContext(obj, create) {
    var ctx = obj._observerContext;
    if (ctx) return ctx();
    if (create) {
        return (obj._observerContext = Sys.Observer._createContext())();
    }
    return null;
}
Sys.Observer._createContext = function Sys$Observer$_createContext() {
    var ctx = {
        events: new Sys.EventHandlerList()
    };
    return function() {
        return ctx;
    }
}
Date._appendPreOrPostMatch = function Date$_appendPreOrPostMatch(preMatch, strBuilder) {
    var quoteCount = 0;
    var escaped = false;
    for (var i = 0, il = preMatch.length; i < il; i++) {
        var c = preMatch.charAt(i);
        switch (c) {
        case '\'':
            if (escaped) strBuilder.append("'");
            else quoteCount++;
            escaped = false;
            break;
        case '\\':
            if (escaped) strBuilder.append("\\");
            escaped = !escaped;
            break;
        default:
            strBuilder.append(c);
            escaped = false;
            break;
        }
    }
    return quoteCount;
}
Date._expandFormat = function Date$_expandFormat(dtf, format) {
    if (!format) {
        format = "F";
    }
    var len = format.length;
    if (len === 1) {
        switch (format) {
        case "d":
            return dtf.ShortDatePattern;
        case "D":
            return dtf.LongDatePattern;
        case "t":
            return dtf.ShortTimePattern;
        case "T":
            return dtf.LongTimePattern;
        case "f":
            return dtf.LongDatePattern + " " + dtf.ShortTimePattern;
        case "F":
            return dtf.FullDateTimePattern;
        case "M": case "m":
            return dtf.MonthDayPattern;
        case "s":
            return dtf.SortableDateTimePattern;
        case "Y": case "y":
            return dtf.YearMonthPattern;
        default:
            throw Error.format(Sys.Res.formatInvalidString);
        }
    }
    else if ((len === 2) && (format.charAt(0) === "%")) {
        format = format.charAt(1);
    }
    return format;
}
Date._expandYear = function Date$_expandYear(dtf, year) {
    var now = new Date(),
        era = Date._getEra(now);
    if (year < 100) {
        var curr = Date._getEraYear(now, dtf, era);
        year += curr - (curr % 100);
        if (year > dtf.Calendar.TwoDigitYearMax) {
            year -= 100;
        }
    }
    return year;
}
Date._getEra = function Date$_getEra(date, eras) {
    if (!eras) return 0;
    var start, ticks = date.getTime();
    for (var i = 0, l = eras.length; i < l; i += 4) {
        start = eras[i+2];
        if ((start === null) || (ticks >= start)) {
            return i;
        }
    }
    return 0;
}
Date._getEraYear = function Date$_getEraYear(date, dtf, era, sortable) {
    var year = date.getFullYear();
    if (!sortable && dtf.eras) {
        year -= dtf.eras[era + 3];
    }    
    return year;
}
Date._getParseRegExp = function Date$_getParseRegExp(dtf, format) {
    if (!dtf._parseRegExp) {
        dtf._parseRegExp = {};
    }
    else if (dtf._parseRegExp[format]) {
        return dtf._parseRegExp[format];
    }
    var expFormat = Date._expandFormat(dtf, format);
    expFormat = expFormat.replace(/([\^\$\.\*\+\?\|\[\]\(\)\{\}])/g, "\\\\$1");
    var regexp = new Sys.StringBuilder("^");
    var groups = [];
    var index = 0;
    var quoteCount = 0;
    var tokenRegExp = Date._getTokenRegExp();
    var match;
    while ((match = tokenRegExp.exec(expFormat)) !== null) {
        var preMatch = expFormat.slice(index, match.index);
        index = tokenRegExp.lastIndex;
        quoteCount += Date._appendPreOrPostMatch(preMatch, regexp);
        if ((quoteCount%2) === 1) {
            regexp.append(match[0]);
            continue;
        }
        switch (match[0]) {
            case 'dddd': case 'ddd':
            case 'MMMM': case 'MMM':
            case 'gg': case 'g':
                regexp.append("(\\D+)");
                break;
            case 'tt': case 't':
                regexp.append("(\\D*)");
                break;
            case 'yyyy':
                regexp.append("(\\d{4})");
                break;
            case 'fff':
                regexp.append("(\\d{3})");
                break;
            case 'ff':
                regexp.append("(\\d{2})");
                break;
            case 'f':
                regexp.append("(\\d)");
                break;
            case 'dd': case 'd':
            case 'MM': case 'M':
            case 'yy': case 'y':
            case 'HH': case 'H':
            case 'hh': case 'h':
            case 'mm': case 'm':
            case 'ss': case 's':
                regexp.append("(\\d\\d?)");
                break;
            case 'zzz':
                regexp.append("([+-]?\\d\\d?:\\d{2})");
                break;
            case 'zz': case 'z':
                regexp.append("([+-]?\\d\\d?)");
                break;
            case '/':
                regexp.append("(\\" + dtf.DateSeparator + ")");
                break;
        }
        Array.add(groups, match[0]);
    }
    Date._appendPreOrPostMatch(expFormat.slice(index), regexp);
    regexp.append("$");
    var regexpStr = regexp.toString().replace(/\s+/g, "\\s+");
    var parseRegExp = {'regExp': regexpStr, 'groups': groups};
    dtf._parseRegExp[format] = parseRegExp;
    return parseRegExp;
}
Date._getTokenRegExp = function Date$_getTokenRegExp() {
    return /\/|dddd|ddd|dd|d|MMMM|MMM|MM|M|yyyy|yy|y|hh|h|HH|H|mm|m|ss|s|tt|t|fff|ff|f|zzz|zz|z|gg|g/g;
}
Date.parseLocale = function Date$parseLocale(value, formats) {
    /// <summary locid="M:J#Date.parseLocale" />
    /// <param name="value" type="String"></param>
    /// <param name="formats" parameterArray="true" optional="true" mayBeNull="true"></param>
    /// <returns type="Date"></returns>
    var e = Function._validateParams(arguments, [
        {name: "value", type: String},
        {name: "formats", mayBeNull: true, optional: true, parameterArray: true}
    ]);
    if (e) throw e;
    return Date._parse(value, Sys.CultureInfo.CurrentCulture, arguments);
}
Date.parseInvariant = function Date$parseInvariant(value, formats) {
    /// <summary locid="M:J#Date.parseInvariant" />
    /// <param name="value" type="String"></param>
    /// <param name="formats" parameterArray="true" optional="true" mayBeNull="true"></param>
    /// <returns type="Date"></returns>
    var e = Function._validateParams(arguments, [
        {name: "value", type: String},
        {name: "formats", mayBeNull: true, optional: true, parameterArray: true}
    ]);
    if (e) throw e;
    return Date._parse(value, Sys.CultureInfo.InvariantCulture, arguments);
}
Date._parse = function Date$_parse(value, cultureInfo, args) {
    var i, l, date, format, formats, custom = false;
    for (i = 1, l = args.length; i < l; i++) {
        format = args[i];
        if (format) {
            custom = true;
            date = Date._parseExact(value, format, cultureInfo);
            if (date) return date;
        }
    }
    if (! custom) {
        formats = cultureInfo._getDateTimeFormats();
        for (i = 0, l = formats.length; i < l; i++) {
            date = Date._parseExact(value, formats[i], cultureInfo);
            if (date) return date;
        }
    }
    return null;
}
Date._parseExact = function Date$_parseExact(value, format, cultureInfo) {
    value = value.trim();
    var dtf = cultureInfo.dateTimeFormat,
        parseInfo = Date._getParseRegExp(dtf, format),
        match = new RegExp(parseInfo.regExp).exec(value);
    if (match === null) return null;
    
    var groups = parseInfo.groups,
        era = null, year = null, month = null, date = null, weekDay = null,
        hour = 0, hourOffset, min = 0, sec = 0, msec = 0, tzMinOffset = null,
        pmHour = false;
    for (var j = 0, jl = groups.length; j < jl; j++) {
        var matchGroup = match[j+1];
        if (matchGroup) {
            switch (groups[j]) {
                case 'dd': case 'd':
                    date = parseInt(matchGroup, 10);
                    if ((date < 1) || (date > 31)) return null;
                    break;
                case 'MMMM':
                    month = cultureInfo._getMonthIndex(matchGroup);
                    if ((month < 0) || (month > 11)) return null;
                    break;
                case 'MMM':
                    month = cultureInfo._getAbbrMonthIndex(matchGroup);
                    if ((month < 0) || (month > 11)) return null;
                    break;
                case 'M': case 'MM':
                    month = parseInt(matchGroup, 10) - 1;
                    if ((month < 0) || (month > 11)) return null;
                    break;
                case 'y': case 'yy':
                    year = Date._expandYear(dtf,parseInt(matchGroup, 10));
                    if ((year < 0) || (year > 9999)) return null;
                    break;
                case 'yyyy':
                    year = parseInt(matchGroup, 10);
                    if ((year < 0) || (year > 9999)) return null;
                    break;
                case 'h': case 'hh':
                    hour = parseInt(matchGroup, 10);
                    if (hour === 12) hour = 0;
                    if ((hour < 0) || (hour > 11)) return null;
                    break;
                case 'H': case 'HH':
                    hour = parseInt(matchGroup, 10);
                    if ((hour < 0) || (hour > 23)) return null;
                    break;
                case 'm': case 'mm':
                    min = parseInt(matchGroup, 10);
                    if ((min < 0) || (min > 59)) return null;
                    break;
                case 's': case 'ss':
                    sec = parseInt(matchGroup, 10);
                    if ((sec < 0) || (sec > 59)) return null;
                    break;
                case 'tt': case 't':
                    var upperToken = matchGroup.toUpperCase();
                    pmHour = (upperToken === dtf.PMDesignator.toUpperCase());
                    if (!pmHour && (upperToken !== dtf.AMDesignator.toUpperCase())) return null;
                    break;
                case 'f':
                    msec = parseInt(matchGroup, 10) * 100;
                    if ((msec < 0) || (msec > 999)) return null;
                    break;
                case 'ff':
                    msec = parseInt(matchGroup, 10) * 10;
                    if ((msec < 0) || (msec > 999)) return null;
                    break;
                case 'fff':
                    msec = parseInt(matchGroup, 10);
                    if ((msec < 0) || (msec > 999)) return null;
                    break;
                case 'dddd':
                    weekDay = cultureInfo._getDayIndex(matchGroup);
                    if ((weekDay < 0) || (weekDay > 6)) return null;
                    break;
                case 'ddd':
                    weekDay = cultureInfo._getAbbrDayIndex(matchGroup);
                    if ((weekDay < 0) || (weekDay > 6)) return null;
                    break;
                case 'zzz':
                    var offsets = matchGroup.split(/:/);
                    if (offsets.length !== 2) return null;
                    hourOffset = parseInt(offsets[0], 10);
                    if ((hourOffset < -12) || (hourOffset > 13)) return null;
                    var minOffset = parseInt(offsets[1], 10);
                    if ((minOffset < 0) || (minOffset > 59)) return null;
                    tzMinOffset = (hourOffset * 60) + (matchGroup.startsWith('-')? -minOffset : minOffset);
                    break;
                case 'z': case 'zz':
                    hourOffset = parseInt(matchGroup, 10);
                    if ((hourOffset < -12) || (hourOffset > 13)) return null;
                    tzMinOffset = hourOffset * 60;
                    break;
                case 'g': case 'gg':
                    var eraName = matchGroup;
                    if (!eraName || !dtf.eras) return null;
                    eraName = eraName.toLowerCase().trim();
                    for (var i = 0, l = dtf.eras.length; i < l; i += 4) {
                        if (eraName === dtf.eras[i + 1].toLowerCase()) {
                            era = i;
                            break;
                        }
                    }
                    if (era === null) return null;
                    break;
            }
        }
    }
    var result = new Date(), defaultYear, convert = dtf.Calendar.convert;
    if (convert) {
        defaultYear = convert.fromGregorian(result)[0];
    }
    else {
        defaultYear = result.getFullYear();
    }
    if (year === null) {
        year = defaultYear;
    }
    else if (dtf.eras) {
        year += dtf.eras[(era || 0) + 3];
    }
    if (month === null) {
        month = 0;
    }
    if (date === null) {
        date = 1;
    }
    if (convert) {
        result = convert.toGregorian(year, month, date);
        if (result === null) return null;
    }
    else {
        result.setFullYear(year, month, date);
        if (result.getDate() !== date) return null;
        if ((weekDay !== null) && (result.getDay() !== weekDay)) {
            return null;
        }
    }
    if (pmHour && (hour < 12)) {
        hour += 12;
    }
    result.setHours(hour, min, sec, msec);
    if (tzMinOffset !== null) {
        var adjustedMin = result.getMinutes() - (tzMinOffset + result.getTimezoneOffset());
        result.setHours(result.getHours() + parseInt(adjustedMin/60, 10), adjustedMin%60);
    }
    return result;
}
Date.prototype.format = function Date$format(format) {
    /// <summary locid="M:J#Date.format" />
    /// <param name="format" type="String"></param>
    /// <returns type="String"></returns>
    var e = Function._validateParams(arguments, [
        {name: "format", type: String}
    ]);
    if (e) throw e;
    return this._toFormattedString(format, Sys.CultureInfo.InvariantCulture);
}
Date.prototype.localeFormat = function Date$localeFormat(format) {
    /// <summary locid="M:J#Date.localeFormat" />
    /// <param name="format" type="String"></param>
    /// <returns type="String"></returns>
    var e = Function._validateParams(arguments, [
        {name: "format", type: String}
    ]);
    if (e) throw e;
    return this._toFormattedString(format, Sys.CultureInfo.CurrentCulture);
}
Date.prototype._toFormattedString = function Date$_toFormattedString(format, cultureInfo) {
    var dtf = cultureInfo.dateTimeFormat,
        convert = dtf.Calendar.convert;
    if (!format || !format.length || (format === 'i')) {
        if (cultureInfo && cultureInfo.name.length) {
            if (convert) {
                return this._toFormattedString(dtf.FullDateTimePattern, cultureInfo);
            }
            else {
                var eraDate = new Date(this.getTime());
                var era = Date._getEra(this, dtf.eras);
                eraDate.setFullYear(Date._getEraYear(this, dtf, era));
                return eraDate.toLocaleString();
            }
        }
        else {
            return this.toString();
        }
    }
    var eras = dtf.eras,
        sortable = (format === "s");
    format = Date._expandFormat(dtf, format);
    var ret = new Sys.StringBuilder();
    var hour;
    function addLeadingZero(num) {
        if (num < 10) {
            return '0' + num;
        }
        return num.toString();
    }
    function addLeadingZeros(num) {
        if (num < 10) {
            return '00' + num;
        }
        if (num < 100) {
            return '0' + num;
        }
        return num.toString();
    }
    function padYear(year) {
        if (year < 10) {
            return '000' + year;
        }
        else if (year < 100) {
            return '00' + year;
        }
        else if (year < 1000) {
            return '0' + year;
        }
        return year.toString();
    }
    
    var foundDay, checkedDay, dayPartRegExp = /([^d]|^)(d|dd)([^d]|$)/g;
    function hasDay() {
        if (foundDay || checkedDay) {
            return foundDay;
        }
        foundDay = dayPartRegExp.test(format);
        checkedDay = true;
        return foundDay;
    }
    
    var quoteCount = 0,
        tokenRegExp = Date._getTokenRegExp(),
        converted;
    if (!sortable && convert) {
        converted = convert.fromGregorian(this);
    }
    for (;;) {
        var index = tokenRegExp.lastIndex;
        var ar = tokenRegExp.exec(format);
        var preMatch = format.slice(index, ar ? ar.index : format.length);
        quoteCount += Date._appendPreOrPostMatch(preMatch, ret);
        if (!ar) break;
        if ((quoteCount%2) === 1) {
            ret.append(ar[0]);
            continue;
        }
        
        function getPart(date, part) {
            if (converted) {
                return converted[part];
            }
            switch (part) {
                case 0: return date.getFullYear();
                case 1: return date.getMonth();
                case 2: return date.getDate();
            }
        }
        switch (ar[0]) {
        case "dddd":
            ret.append(dtf.DayNames[this.getDay()]);
            break;
        case "ddd":
            ret.append(dtf.AbbreviatedDayNames[this.getDay()]);
            break;
        case "dd":
            foundDay = true;
            ret.append(addLeadingZero(getPart(this, 2)));
            break;
        case "d":
            foundDay = true;
            ret.append(getPart(this, 2));
            break;
        case "MMMM":
            ret.append((dtf.MonthGenitiveNames && hasDay())
                ? dtf.MonthGenitiveNames[getPart(this, 1)]
                : dtf.MonthNames[getPart(this, 1)]);
            break;
        case "MMM":
            ret.append((dtf.AbbreviatedMonthGenitiveNames && hasDay())
                ? dtf.AbbreviatedMonthGenitiveNames[getPart(this, 1)]
                : dtf.AbbreviatedMonthNames[getPart(this, 1)]);
            break;
        case "MM":
            ret.append(addLeadingZero(getPart(this, 1) + 1));
            break;
        case "M":
            ret.append(getPart(this, 1) + 1);
            break;
        case "yyyy":
            ret.append(padYear(converted ? converted[0] : Date._getEraYear(this, dtf, Date._getEra(this, eras), sortable)));
            break;
        case "yy":
            ret.append(addLeadingZero((converted ? converted[0] : Date._getEraYear(this, dtf, Date._getEra(this, eras), sortable)) % 100));
            break;
        case "y":
            ret.append((converted ? converted[0] : Date._getEraYear(this, dtf, Date._getEra(this, eras), sortable)) % 100);
            break;
        case "hh":
            hour = this.getHours() % 12;
            if (hour === 0) hour = 12;
            ret.append(addLeadingZero(hour));
            break;
        case "h":
            hour = this.getHours() % 12;
            if (hour === 0) hour = 12;
            ret.append(hour);
            break;
        case "HH":
            ret.append(addLeadingZero(this.getHours()));
            break;
        case "H":
            ret.append(this.getHours());
            break;
        case "mm":
            ret.append(addLeadingZero(this.getMinutes()));
            break;
        case "m":
            ret.append(this.getMinutes());
            break;
        case "ss":
            ret.append(addLeadingZero(this.getSeconds()));
            break;
        case "s":
            ret.append(this.getSeconds());
            break;
        case "tt":
            ret.append((this.getHours() < 12) ? dtf.AMDesignator : dtf.PMDesignator);
            break;
        case "t":
            ret.append(((this.getHours() < 12) ? dtf.AMDesignator : dtf.PMDesignator).charAt(0));
            break;
        case "f":
            ret.append(addLeadingZeros(this.getMilliseconds()).charAt(0));
            break;
        case "ff":
            ret.append(addLeadingZeros(this.getMilliseconds()).substr(0, 2));
            break;
        case "fff":
            ret.append(addLeadingZeros(this.getMilliseconds()));
            break;
        case "z":
            hour = this.getTimezoneOffset() / 60;
            ret.append(((hour <= 0) ? '+' : '-') + Math.floor(Math.abs(hour)));
            break;
        case "zz":
            hour = this.getTimezoneOffset() / 60;
            ret.append(((hour <= 0) ? '+' : '-') + addLeadingZero(Math.floor(Math.abs(hour))));
            break;
        case "zzz":
            hour = this.getTimezoneOffset() / 60;
            ret.append(((hour <= 0) ? '+' : '-') + addLeadingZero(Math.floor(Math.abs(hour))) +
                ":" + addLeadingZero(Math.abs(this.getTimezoneOffset() % 60)));
            break;
        case "g":
        case "gg":
            if (dtf.eras) {
                ret.append(dtf.eras[Date._getEra(this, eras) + 1]);
            }
            break;
        case "/":
            ret.append(dtf.DateSeparator);
            break;
        }
    }
    return ret.toString();
}
String.localeFormat = function String$localeFormat(format, args) {
    /// <summary locid="M:J#String.localeFormat" />
    /// <param name="format" type="String"></param>
    /// <param name="args" parameterArray="true" mayBeNull="true"></param>
    /// <returns type="String"></returns>
    var e = Function._validateParams(arguments, [
        {name: "format", type: String},
        {name: "args", mayBeNull: true, parameterArray: true}
    ]);
    if (e) throw e;
    return String._toFormattedString(true, arguments);
}
Number.parseLocale = function Number$parseLocale(value) {
    /// <summary locid="M:J#Number.parseLocale" />
    /// <param name="value" type="String"></param>
    /// <returns type="Number"></returns>
    var e = Function._validateParams(arguments, [
        {name: "value", type: String}
    ], false);
    if (e) throw e;
    return Number._parse(value, Sys.CultureInfo.CurrentCulture);
}
Number.parseInvariant = function Number$parseInvariant(value) {
    /// <summary locid="M:J#Number.parseInvariant" />
    /// <param name="value" type="String"></param>
    /// <returns type="Number"></returns>
    var e = Function._validateParams(arguments, [
        {name: "value", type: String}
    ], false);
    if (e) throw e;
    return Number._parse(value, Sys.CultureInfo.InvariantCulture);
}
Number._parse = function Number$_parse(value, cultureInfo) {
    value = value.trim();
    
    if (value.match(/^[+-]?infinity$/i)) {
        return parseFloat(value);
    }
    if (value.match(/^0x[a-f0-9]+$/i)) {
        return parseInt(value);
    }
    var numFormat = cultureInfo.numberFormat;
    var signInfo = Number._parseNumberNegativePattern(value, numFormat, numFormat.NumberNegativePattern);
    var sign = signInfo[0];
    var num = signInfo[1];
    
    if ((sign === '') && (numFormat.NumberNegativePattern !== 1)) {
        signInfo = Number._parseNumberNegativePattern(value, numFormat, 1);
        sign = signInfo[0];
        num = signInfo[1];
    }
    if (sign === '') sign = '+';
    
    var exponent;
    var intAndFraction;
    var exponentPos = num.indexOf('e');
    if (exponentPos < 0) exponentPos = num.indexOf('E');
    if (exponentPos < 0) {
        intAndFraction = num;
        exponent = null;
    }
    else {
        intAndFraction = num.substr(0, exponentPos);
        exponent = num.substr(exponentPos + 1);
    }
    
    var integer;
    var fraction;
    var decimalPos = intAndFraction.indexOf(numFormat.NumberDecimalSeparator);
    if (decimalPos < 0) {
        integer = intAndFraction;
        fraction = null;
    }
    else {
        integer = intAndFraction.substr(0, decimalPos);
        fraction = intAndFraction.substr(decimalPos + numFormat.NumberDecimalSeparator.length);
    }
    
    integer = integer.split(numFormat.NumberGroupSeparator).join('');
    var altNumGroupSeparator = numFormat.NumberGroupSeparator.replace(/\u00A0/g, " ");
    if (numFormat.NumberGroupSeparator !== altNumGroupSeparator) {
        integer = integer.split(altNumGroupSeparator).join('');
    }
    
    var p = sign + integer;
    if (fraction !== null) {
        p += '.' + fraction;
    }
    if (exponent !== null) {
        var expSignInfo = Number._parseNumberNegativePattern(exponent, numFormat, 1);
        if (expSignInfo[0] === '') {
            expSignInfo[0] = '+';
        }
        p += 'e' + expSignInfo[0] + expSignInfo[1];
    }
    if (p.match(/^[+-]?\d*\.?\d*(e[+-]?\d+)?$/)) {
        return parseFloat(p);
    }
    return Number.NaN;
}
Number._parseNumberNegativePattern = function Number$_parseNumberNegativePattern(value, numFormat, numberNegativePattern) {
    var neg = numFormat.NegativeSign;
    var pos = numFormat.PositiveSign;    
    switch (numberNegativePattern) {
        case 4: 
            neg = ' ' + neg;
            pos = ' ' + pos;
        case 3: 
            if (value.endsWith(neg)) {
                return ['-', value.substr(0, value.length - neg.length)];
            }
            else if (value.endsWith(pos)) {
                return ['+', value.substr(0, value.length - pos.length)];
            }
            break;
        case 2: 
            neg += ' ';
            pos += ' ';
        case 1: 
            if (value.startsWith(neg)) {
                return ['-', value.substr(neg.length)];
            }
            else if (value.startsWith(pos)) {
                return ['+', value.substr(pos.length)];
            }
            break;
        case 0: 
            if (value.startsWith('(') && value.endsWith(')')) {
                return ['-', value.substr(1, value.length - 2)];
            }
            break;
    }
    return ['', value];
}
Number.prototype.format = function Number$format(format) {
    /// <summary locid="M:J#Number.format" />
    /// <param name="format" type="String"></param>
    /// <returns type="String"></returns>
    var e = Function._validateParams(arguments, [
        {name: "format", type: String}
    ]);
    if (e) throw e;
    return this._toFormattedString(format, Sys.CultureInfo.InvariantCulture);
}
Number.prototype.localeFormat = function Number$localeFormat(format) {
    /// <summary locid="M:J#Number.localeFormat" />
    /// <param name="format" type="String"></param>
    /// <returns type="String"></returns>
    var e = Function._validateParams(arguments, [
        {name: "format", type: String}
    ]);
    if (e) throw e;
    return this._toFormattedString(format, Sys.CultureInfo.CurrentCulture);
}
Number.prototype._toFormattedString = function Number$_toFormattedString(format, cultureInfo) {
    if (!format || (format.length === 0) || (format === 'i')) {
        if (cultureInfo && (cultureInfo.name.length > 0)) {
            return this.toLocaleString();
        }
        else {
            return this.toString();
        }
    }
    
    var _percentPositivePattern = ["n %", "n%", "%n" ];
    var _percentNegativePattern = ["-n %", "-n%", "-%n"];
    var _numberNegativePattern = ["(n)","-n","- n","n-","n -"];
    var _currencyPositivePattern = ["$n","n$","$ n","n $"];
    var _currencyNegativePattern = ["($n)","-$n","$-n","$n-","(n$)","-n$","n-$","n$-","-n $","-$ n","n $-","$ n-","$ -n","n- $","($ n)","(n $)"];
    function zeroPad(str, count, left) {
        for (var l=str.length; l < count; l++) {
            str = (left ? ('0' + str) : (str + '0'));
        }
        return str;
    }
    
    function expandNumber(number, precision, groupSizes, sep, decimalChar) {
        
        var curSize = groupSizes[0];
        var curGroupIndex = 1;
        var factor = Math.pow(10, precision);
        var rounded = (Math.round(number * factor) / factor);
        if (!isFinite(rounded)) {
            rounded = number;
        }
        number = rounded;
        
        var numberString = number.toString();
        var right = "";
        var exponent;
        
        
        var split = numberString.split(/e/i);
        numberString = split[0];
        exponent = (split.length > 1 ? parseInt(split[1]) : 0);
        split = numberString.split('.');
        numberString = split[0];
        right = split.length > 1 ? split[1] : "";
        
        var l;
        if (exponent > 0) {
            right = zeroPad(right, exponent, false);
            numberString += right.slice(0, exponent);
            right = right.substr(exponent);
        }
        else if (exponent < 0) {
            exponent = -exponent;
            numberString = zeroPad(numberString, exponent+1, true);
            right = numberString.slice(-exponent, numberString.length) + right;
            numberString = numberString.slice(0, -exponent);
        }
        if (precision > 0) {
            if (right.length > precision) {
                right = right.slice(0, precision);
            }
            else {
                right = zeroPad(right, precision, false);
            }
            right = decimalChar + right;
        }
        else { 
            right = "";
        }
        var stringIndex = numberString.length-1;
        var ret = "";
        while (stringIndex >= 0) {
            if (curSize === 0 || curSize > stringIndex) {
                if (ret.length > 0)
                    return numberString.slice(0, stringIndex + 1) + sep + ret + right;
                else
                    return numberString.slice(0, stringIndex + 1) + right;
            }
            if (ret.length > 0)
                ret = numberString.slice(stringIndex - curSize + 1, stringIndex+1) + sep + ret;
            else
                ret = numberString.slice(stringIndex - curSize + 1, stringIndex+1);
            stringIndex -= curSize;
            if (curGroupIndex < groupSizes.length) {
                curSize = groupSizes[curGroupIndex];
                curGroupIndex++;
            }
        }
        return numberString.slice(0, stringIndex + 1) + sep + ret + right;
    }
    var nf = cultureInfo.numberFormat;
    var number = Math.abs(this);
    if (!format)
        format = "D";
    var precision = -1;
    if (format.length > 1) precision = parseInt(format.slice(1), 10);
    var pattern;
    switch (format.charAt(0)) {
    case "d":
    case "D":
        pattern = 'n';
        if (precision !== -1) {
            number = zeroPad(""+number, precision, true);
        }
        if (this < 0) number = -number;
        break;
    case "c":
    case "C":
        if (this < 0) pattern = _currencyNegativePattern[nf.CurrencyNegativePattern];
        else pattern = _currencyPositivePattern[nf.CurrencyPositivePattern];
        if (precision === -1) precision = nf.CurrencyDecimalDigits;
        number = expandNumber(Math.abs(this), precision, nf.CurrencyGroupSizes, nf.CurrencyGroupSeparator, nf.CurrencyDecimalSeparator);
        break;
    case "n":
    case "N":
        if (this < 0) pattern = _numberNegativePattern[nf.NumberNegativePattern];
        else pattern = 'n';
        if (precision === -1) precision = nf.NumberDecimalDigits;
        number = expandNumber(Math.abs(this), precision, nf.NumberGroupSizes, nf.NumberGroupSeparator, nf.NumberDecimalSeparator);
        break;
    case "p":
    case "P":
        if (this < 0) pattern = _percentNegativePattern[nf.PercentNegativePattern];
        else pattern = _percentPositivePattern[nf.PercentPositivePattern];
        if (precision === -1) precision = nf.PercentDecimalDigits;
        number = expandNumber(Math.abs(this) * 100, precision, nf.PercentGroupSizes, nf.PercentGroupSeparator, nf.PercentDecimalSeparator);
        break;
    default:
        throw Error.format(Sys.Res.formatBadFormatSpecifier);
    }
    var regex = /n|\$|-|%/g;
    var ret = "";
    for (;;) {
        var index = regex.lastIndex;
        var ar = regex.exec(pattern);
        ret += pattern.slice(index, ar ? ar.index : pattern.length);
        if (!ar)
            break;
        switch (ar[0]) {
        case "n":
            ret += number;
            break;
        case "$":
            ret += nf.CurrencySymbol;
            break;
        case "-":
            if (/[1-9]/.test(number)) {
                ret += nf.NegativeSign;
            }
            break;
        case "%":
            ret += nf.PercentSymbol;
            break;
        }
    }
    return ret;
}
 
Sys.CultureInfo = function Sys$CultureInfo(name, numberFormat, dateTimeFormat) {
    /// <summary locid="M:J#Sys.CultureInfo.#ctor" />
    /// <param name="name" type="String"></param>
    /// <param name="numberFormat" type="Object"></param>
    /// <param name="dateTimeFormat" type="Object"></param>
    var e = Function._validateParams(arguments, [
        {name: "name", type: String},
        {name: "numberFormat", type: Object},
        {name: "dateTimeFormat", type: Object}
    ]);
    if (e) throw e;
    this.name = name;
    this.numberFormat = numberFormat;
    this.dateTimeFormat = dateTimeFormat;
}
    function Sys$CultureInfo$_getDateTimeFormats() {
        if (! this._dateTimeFormats) {
            var dtf = this.dateTimeFormat;
            this._dateTimeFormats =
              [ dtf.MonthDayPattern,
                dtf.YearMonthPattern,
                dtf.ShortDatePattern,
                dtf.ShortTimePattern,
                dtf.LongDatePattern,
                dtf.LongTimePattern,
                dtf.FullDateTimePattern,
                dtf.RFC1123Pattern,
                dtf.SortableDateTimePattern,
                dtf.UniversalSortableDateTimePattern ];
        }
        return this._dateTimeFormats;
    }
    function Sys$CultureInfo$_getIndex(value, a1, a2) {
        var upper = this._toUpper(value),
            i = Array.indexOf(a1, upper);
        if (i === -1) {
            i = Array.indexOf(a2, upper);
        }
        return i;
    }
    function Sys$CultureInfo$_getMonthIndex(value) {
        if (!this._upperMonths) {
            this._upperMonths = this._toUpperArray(this.dateTimeFormat.MonthNames);
            this._upperMonthsGenitive = this._toUpperArray(this.dateTimeFormat.MonthGenitiveNames);
        }
        return this._getIndex(value, this._upperMonths, this._upperMonthsGenitive);
    }
    function Sys$CultureInfo$_getAbbrMonthIndex(value) {
        if (!this._upperAbbrMonths) {
            this._upperAbbrMonths = this._toUpperArray(this.dateTimeFormat.AbbreviatedMonthNames);
            this._upperAbbrMonthsGenitive = this._toUpperArray(this.dateTimeFormat.AbbreviatedMonthGenitiveNames);
        }
        return this._getIndex(value, this._upperAbbrMonths, this._upperAbbrMonthsGenitive);
    }
    function Sys$CultureInfo$_getDayIndex(value) {
        if (!this._upperDays) {
            this._upperDays = this._toUpperArray(this.dateTimeFormat.DayNames);
        }
        return Array.indexOf(this._upperDays, this._toUpper(value));
    }
    function Sys$CultureInfo$_getAbbrDayIndex(value) {
        if (!this._upperAbbrDays) {
            this._upperAbbrDays = this._toUpperArray(this.dateTimeFormat.AbbreviatedDayNames);
        }
        return Array.indexOf(this._upperAbbrDays, this._toUpper(value));
    }
    function Sys$CultureInfo$_toUpperArray(arr) {
        var result = [];
        for (var i = 0, il = arr.length; i < il; i++) {
            result[i] = this._toUpper(arr[i]);
        }
        return result;
    }
    function Sys$CultureInfo$_toUpper(value) {
        return value.split("\u00A0").join(' ').toUpperCase();
    }
Sys.CultureInfo.prototype = {
    _getDateTimeFormats: Sys$CultureInfo$_getDateTimeFormats,
    _getIndex: Sys$CultureInfo$_getIndex,
    _getMonthIndex: Sys$CultureInfo$_getMonthIndex,
    _getAbbrMonthIndex: Sys$CultureInfo$_getAbbrMonthIndex,
    _getDayIndex: Sys$CultureInfo$_getDayIndex,
    _getAbbrDayIndex: Sys$CultureInfo$_getAbbrDayIndex,
    _toUpperArray: Sys$CultureInfo$_toUpperArray,
    _toUpper: Sys$CultureInfo$_toUpper
}
Sys.CultureInfo.registerClass('Sys.CultureInfo');
Sys.CultureInfo._parse = function Sys$CultureInfo$_parse(value) {
    var dtf = value.dateTimeFormat;
    if (dtf && !dtf.eras) {
        dtf.eras = value.eras;
    }
    return new Sys.CultureInfo(value.name, value.numberFormat, dtf);
}
Sys.CultureInfo.InvariantCulture = Sys.CultureInfo._parse({"name":"","numberFormat":{"CurrencyDecimalDigits":2,"CurrencyDecimalSeparator":".","IsReadOnly":true,"CurrencyGroupSizes":[3],"NumberGroupSizes":[3],"PercentGroupSizes":[3],"CurrencyGroupSeparator":",","CurrencySymbol":"\u00A4","NaNSymbol":"NaN","CurrencyNegativePattern":0,"NumberNegativePattern":1,"PercentPositivePattern":0,"PercentNegativePattern":0,"NegativeInfinitySymbol":"-Infinity","NegativeSign":"-","NumberDecimalDigits":2,"NumberDecimalSeparator":".","NumberGroupSeparator":",","CurrencyPositivePattern":0,"PositiveInfinitySymbol":"Infinity","PositiveSign":"+","PercentDecimalDigits":2,"PercentDecimalSeparator":".","PercentGroupSeparator":",","PercentSymbol":"%","PerMilleSymbol":"\u2030","NativeDigits":["0","1","2","3","4","5","6","7","8","9"],"DigitSubstitution":1},"dateTimeFormat":{"AMDesignator":"AM","Calendar":{"MinSupportedDateTime":"@-62135568000000@","MaxSupportedDateTime":"@253402300799999@","AlgorithmType":1,"CalendarType":1,"Eras":[1],"TwoDigitYearMax":2029,"IsReadOnly":true},"DateSeparator":"/","FirstDayOfWeek":0,"CalendarWeekRule":0,"FullDateTimePattern":"dddd, dd MMMM yyyy HH:mm:ss","LongDatePattern":"dddd, dd MMMM yyyy","LongTimePattern":"HH:mm:ss","MonthDayPattern":"MMMM dd","PMDesignator":"PM","RFC1123Pattern":"ddd, dd MMM yyyy HH\':\'mm\':\'ss \'GMT\'","ShortDatePattern":"MM/dd/yyyy","ShortTimePattern":"HH:mm","SortableDateTimePattern":"yyyy\'-\'MM\'-\'dd\'T\'HH\':\'mm\':\'ss","TimeSeparator":":","UniversalSortableDateTimePattern":"yyyy\'-\'MM\'-\'dd HH\':\'mm\':\'ss\'Z\'","YearMonthPattern":"yyyy MMMM","AbbreviatedDayNames":["Sun","Mon","Tue","Wed","Thu","Fri","Sat"],"ShortestDayNames":["Su","Mo","Tu","We","Th","Fr","Sa"],"DayNames":["Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"],"AbbreviatedMonthNames":["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec",""],"MonthNames":["January","February","March","April","May","June","July","August","September","October","November","December",""],"IsReadOnly":true,"NativeCalendarName":"Gregorian Calendar","AbbreviatedMonthGenitiveNames":["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec",""],"MonthGenitiveNames":["January","February","March","April","May","June","July","August","September","October","November","December",""]},"eras":[1,"A.D.",null,0]});
if (typeof(__cultureInfo) === "object") {
    Sys.CultureInfo.CurrentCulture = Sys.CultureInfo._parse(__cultureInfo);
    delete __cultureInfo;    
}
else {
    Sys.CultureInfo.CurrentCulture = Sys.CultureInfo._parse({"name":"en-US","numberFormat":{"CurrencyDecimalDigits":2,"CurrencyDecimalSeparator":".","IsReadOnly":false,"CurrencyGroupSizes":[3],"NumberGroupSizes":[3],"PercentGroupSizes":[3],"CurrencyGroupSeparator":",","CurrencySymbol":"$","NaNSymbol":"NaN","CurrencyNegativePattern":0,"NumberNegativePattern":1,"PercentPositivePattern":0,"PercentNegativePattern":0,"NegativeInfinitySymbol":"-Infinity","NegativeSign":"-","NumberDecimalDigits":2,"NumberDecimalSeparator":".","NumberGroupSeparator":",","CurrencyPositivePattern":0,"PositiveInfinitySymbol":"Infinity","PositiveSign":"+","PercentDecimalDigits":2,"PercentDecimalSeparator":".","PercentGroupSeparator":",","PercentSymbol":"%","PerMilleSymbol":"\u2030","NativeDigits":["0","1","2","3","4","5","6","7","8","9"],"DigitSubstitution":1},"dateTimeFormat":{"AMDesignator":"AM","Calendar":{"MinSupportedDateTime":"@-62135568000000@","MaxSupportedDateTime":"@253402300799999@","AlgorithmType":1,"CalendarType":1,"Eras":[1],"TwoDigitYearMax":2029,"IsReadOnly":false},"DateSeparator":"/","FirstDayOfWeek":0,"CalendarWeekRule":0,"FullDateTimePattern":"dddd, MMMM dd, yyyy h:mm:ss tt","LongDatePattern":"dddd, MMMM dd, yyyy","LongTimePattern":"h:mm:ss tt","MonthDayPattern":"MMMM dd","PMDesignator":"PM","RFC1123Pattern":"ddd, dd MMM yyyy HH\':\'mm\':\'ss \'GMT\'","ShortDatePattern":"M/d/yyyy","ShortTimePattern":"h:mm tt","SortableDateTimePattern":"yyyy\'-\'MM\'-\'dd\'T\'HH\':\'mm\':\'ss","TimeSeparator":":","UniversalSortableDateTimePattern":"yyyy\'-\'MM\'-\'dd HH\':\'mm\':\'ss\'Z\'","YearMonthPattern":"MMMM, yyyy","AbbreviatedDayNames":["Sun","Mon","Tue","Wed","Thu","Fri","Sat"],"ShortestDayNames":["Su","Mo","Tu","We","Th","Fr","Sa"],"DayNames":["Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"],"AbbreviatedMonthNames":["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec",""],"MonthNames":["January","February","March","April","May","June","July","August","September","October","November","December",""],"IsReadOnly":false,"NativeCalendarName":"Gregorian Calendar","AbbreviatedMonthGenitiveNames":["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec",""],"MonthGenitiveNames":["January","February","March","April","May","June","July","August","September","October","November","December",""]},"eras":[1,"A.D.",null,0]});
}
Type.registerNamespace('Sys.Serialization');
Sys.Serialization.JavaScriptSerializer = function Sys$Serialization$JavaScriptSerializer() {
    /// <summary locid="M:J#Sys.Serialization.JavaScriptSerializer.#ctor" />
    if (arguments.length !== 0) throw Error.parameterCount();
}
Sys.Serialization.JavaScriptSerializer.registerClass('Sys.Serialization.JavaScriptSerializer');
Sys.Serialization.JavaScriptSerializer._charsToEscapeRegExs = [];
Sys.Serialization.JavaScriptSerializer._charsToEscape = [];
Sys.Serialization.JavaScriptSerializer._dateRegEx = new RegExp('(^|[^\\\\])\\"\\\\/Date\\((-?[0-9]+)(?:[a-zA-Z]|(?:\\+|-)[0-9]{4})?\\)\\\\/\\"', 'g');
Sys.Serialization.JavaScriptSerializer._escapeChars = {};
Sys.Serialization.JavaScriptSerializer._escapeRegEx = new RegExp('["\\\\\\x00-\\x1F]', 'i');
Sys.Serialization.JavaScriptSerializer._escapeRegExGlobal = new RegExp('["\\\\\\x00-\\x1F]', 'g');
Sys.Serialization.JavaScriptSerializer._jsonRegEx = new RegExp('[^,:{}\\[\\]0-9.\\-+Eaeflnr-u \\n\\r\\t]', 'g');
Sys.Serialization.JavaScriptSerializer._jsonStringRegEx = new RegExp('"(\\\\.|[^"\\\\])*"', 'g');
Sys.Serialization.JavaScriptSerializer._serverTypeFieldName = '__type';
Sys.Serialization.JavaScriptSerializer._init = function Sys$Serialization$JavaScriptSerializer$_init() {
    var replaceChars = ['\\u0000','\\u0001','\\u0002','\\u0003','\\u0004','\\u0005','\\u0006','\\u0007',
                        '\\b','\\t','\\n','\\u000b','\\f','\\r','\\u000e','\\u000f','\\u0010','\\u0011',
                        '\\u0012','\\u0013','\\u0014','\\u0015','\\u0016','\\u0017','\\u0018','\\u0019',
                        '\\u001a','\\u001b','\\u001c','\\u001d','\\u001e','\\u001f'];
    Sys.Serialization.JavaScriptSerializer._charsToEscape[0] = '\\';
    Sys.Serialization.JavaScriptSerializer._charsToEscapeRegExs['\\'] = new RegExp('\\\\', 'g');
    Sys.Serialization.JavaScriptSerializer._escapeChars['\\'] = '\\\\';
    Sys.Serialization.JavaScriptSerializer._charsToEscape[1] = '"';
    Sys.Serialization.JavaScriptSerializer._charsToEscapeRegExs['"'] = new RegExp('"', 'g');
    Sys.Serialization.JavaScriptSerializer._escapeChars['"'] = '\\"';
    for (var i = 0; i < 32; i++) {
        var c = String.fromCharCode(i);
        Sys.Serialization.JavaScriptSerializer._charsToEscape[i+2] = c;
        Sys.Serialization.JavaScriptSerializer._charsToEscapeRegExs[c] = new RegExp(c, 'g');
        Sys.Serialization.JavaScriptSerializer._escapeChars[c] = replaceChars[i];
    }
}
Sys.Serialization.JavaScriptSerializer._serializeBooleanWithBuilder = function Sys$Serialization$JavaScriptSerializer$_serializeBooleanWithBuilder(object, stringBuilder) {
    stringBuilder.append(object.toString());
}
Sys.Serialization.JavaScriptSerializer._serializeNumberWithBuilder = function Sys$Serialization$JavaScriptSerializer$_serializeNumberWithBuilder(object, stringBuilder) {
    if (isFinite(object)) {
        stringBuilder.append(String(object));
    }
    else {
        throw Error.invalidOperation(Sys.Res.cannotSerializeNonFiniteNumbers);
    }
}
Sys.Serialization.JavaScriptSerializer._serializeStringWithBuilder = function Sys$Serialization$JavaScriptSerializer$_serializeStringWithBuilder(string, stringBuilder) {
    stringBuilder.append('"');
    if (Sys.Serialization.JavaScriptSerializer._escapeRegEx.test(string)) {
        if (Sys.Serialization.JavaScriptSerializer._charsToEscape.length === 0) {
            Sys.Serialization.JavaScriptSerializer._init();
        }
        if (string.length < 128) {
            string = string.replace(Sys.Serialization.JavaScriptSerializer._escapeRegExGlobal,
                function(x) { return Sys.Serialization.JavaScriptSerializer._escapeChars[x]; });
        }
        else {
            for (var i = 0; i < 34; i++) {
                var c = Sys.Serialization.JavaScriptSerializer._charsToEscape[i];
                if (string.indexOf(c) !== -1) {
                    if (Sys.Browser.agent === Sys.Browser.Opera || Sys.Browser.agent === Sys.Browser.FireFox) {
                        string = string.split(c).join(Sys.Serialization.JavaScriptSerializer._escapeChars[c]);
                    }
                    else {
                        string = string.replace(Sys.Serialization.JavaScriptSerializer._charsToEscapeRegExs[c],
                            Sys.Serialization.JavaScriptSerializer._escapeChars[c]);
                    }
                }
            }
       }
    }
    stringBuilder.append(string);
    stringBuilder.append('"');
}
Sys.Serialization.JavaScriptSerializer._serializeWithBuilder = function Sys$Serialization$JavaScriptSerializer$_serializeWithBuilder(object, stringBuilder, sort, prevObjects) {
    var i;
    switch (typeof object) {
    case 'object':
        if (object) {
            if (prevObjects){
                for( var j = 0; j < prevObjects.length; j++) {
                    if (prevObjects[j] === object) {
                        throw Error.invalidOperation(Sys.Res.cannotSerializeObjectWithCycle);
                    }
                }
            }
            else {
                prevObjects = new Array();
            }
            try {
                Array.add(prevObjects, object);
                
                if (Number.isInstanceOfType(object)){
                    Sys.Serialization.JavaScriptSerializer._serializeNumberWithBuilder(object, stringBuilder);
                }
                else if (Boolean.isInstanceOfType(object)){
                    Sys.Serialization.JavaScriptSerializer._serializeBooleanWithBuilder(object, stringBuilder);
                }
                else if (String.isInstanceOfType(object)){
                    Sys.Serialization.JavaScriptSerializer._serializeStringWithBuilder(object, stringBuilder);
                }
            
                else if (Array.isInstanceOfType(object)) {
                    stringBuilder.append('[');
                   
                    for (i = 0; i < object.length; ++i) {
                        if (i > 0) {
                            stringBuilder.append(',');
                        }
                        Sys.Serialization.JavaScriptSerializer._serializeWithBuilder(object[i], stringBuilder,false,prevObjects);
                    }
                    stringBuilder.append(']');
                }
                else {
                    if (Date.isInstanceOfType(object)) {
                        stringBuilder.append('"\\/Date(');
                        stringBuilder.append(object.getTime());
                        stringBuilder.append(')\\/"');
                        break;
                    }
                    var properties = [];
                    var propertyCount = 0;
                    for (var name in object) {
                        if (name.startsWith('$')) {
                            continue;
                        }
                        if (name === Sys.Serialization.JavaScriptSerializer._serverTypeFieldName && propertyCount !== 0){
                            properties[propertyCount++] = properties[0];
                            properties[0] = name;
                        }
                        else{
                            properties[propertyCount++] = name;
                        }
                    }
                    if (sort) properties.sort();
                    stringBuilder.append('{');
                    var needComma = false;
                     
                    for (i=0; i<propertyCount; i++) {
                        var value = object[properties[i]];
                        if (typeof value !== 'undefined' && typeof value !== 'function') {
                            if (needComma) {
                                stringBuilder.append(',');
                            }
                            else {
                                needComma = true;
                            }
                           
                            Sys.Serialization.JavaScriptSerializer._serializeWithBuilder(properties[i], stringBuilder, sort, prevObjects);
                            stringBuilder.append(':');
                            Sys.Serialization.JavaScriptSerializer._serializeWithBuilder(value, stringBuilder, sort, prevObjects);
                          
                        }
                    }
                stringBuilder.append('}');
                }
            }
            finally {
                Array.removeAt(prevObjects, prevObjects.length - 1);
            }
        }
        else {
            stringBuilder.append('null');
        }
        break;
    case 'number':
        Sys.Serialization.JavaScriptSerializer._serializeNumberWithBuilder(object, stringBuilder);
        break;
    case 'string':
        Sys.Serialization.JavaScriptSerializer._serializeStringWithBuilder(object, stringBuilder);
        break;
    case 'boolean':
        Sys.Serialization.JavaScriptSerializer._serializeBooleanWithBuilder(object, stringBuilder);
        break;
    default:
        stringBuilder.append('null');
        break;
    }
}
Sys.Serialization.JavaScriptSerializer.serialize = function Sys$Serialization$JavaScriptSerializer$serialize(object) {
    /// <summary locid="M:J#Sys.Serialization.JavaScriptSerializer.serialize" />
    /// <param name="object" mayBeNull="true"></param>
    /// <returns type="String"></returns>
    var e = Function._validateParams(arguments, [
        {name: "object", mayBeNull: true}
    ]);
    if (e) throw e;
    var stringBuilder = new Sys.StringBuilder();
    Sys.Serialization.JavaScriptSerializer._serializeWithBuilder(object, stringBuilder, false);
    return stringBuilder.toString();
}
Sys.Serialization.JavaScriptSerializer.deserialize = function Sys$Serialization$JavaScriptSerializer$deserialize(data, secure) {
    /// <summary locid="M:J#Sys.Serialization.JavaScriptSerializer.deserialize" />
    /// <param name="data" type="String"></param>
    /// <param name="secure" type="Boolean" optional="true"></param>
    /// <returns></returns>
    var e = Function._validateParams(arguments, [
        {name: "data", type: String},
        {name: "secure", type: Boolean, optional: true}
    ]);
    if (e) throw e;
    
    if (data.length === 0) throw Error.argument('data', Sys.Res.cannotDeserializeEmptyString);
    try {    
        var exp = data.replace(Sys.Serialization.JavaScriptSerializer._dateRegEx, "$1new Date($2)");
        
        if (secure && Sys.Serialization.JavaScriptSerializer._jsonRegEx.test(
             exp.replace(Sys.Serialization.JavaScriptSerializer._jsonStringRegEx, ''))) throw null;
        return eval('(' + exp + ')');
    }
    catch (e) {
         throw Error.argument('data', Sys.Res.cannotDeserializeInvalidJson);
    }
}
Type.registerNamespace('Sys.UI');
 
Sys.EventHandlerList = function Sys$EventHandlerList() {
    /// <summary locid="M:J#Sys.EventHandlerList.#ctor" />
    if (arguments.length !== 0) throw Error.parameterCount();
    this._list = {};
}
    function Sys$EventHandlerList$_addHandler(id, handler) {
        Array.add(this._getEvent(id, true), handler);
    }
    function Sys$EventHandlerList$addHandler(id, handler) {
        /// <summary locid="M:J#Sys.EventHandlerList.addHandler" />
        /// <param name="id" type="String"></param>
        /// <param name="handler" type="Function"></param>
        var e = Function._validateParams(arguments, [
            {name: "id", type: String},
            {name: "handler", type: Function}
        ]);
        if (e) throw e;
        this._addHandler(id, handler);
    }
    function Sys$EventHandlerList$_removeHandler(id, handler) {
        var evt = this._getEvent(id);
        if (!evt) return;
        Array.remove(evt, handler);
    }
    function Sys$EventHandlerList$removeHandler(id, handler) {
        /// <summary locid="M:J#Sys.EventHandlerList.removeHandler" />
        /// <param name="id" type="String"></param>
        /// <param name="handler" type="Function"></param>
        var e = Function._validateParams(arguments, [
            {name: "id", type: String},
            {name: "handler", type: Function}
        ]);
        if (e) throw e;
        this._removeHandler(id, handler);
    }
    function Sys$EventHandlerList$getHandler(id) {
        /// <summary locid="M:J#Sys.EventHandlerList.getHandler" />
        /// <param name="id" type="String"></param>
        /// <returns type="Function"></returns>
        var e = Function._validateParams(arguments, [
            {name: "id", type: String}
        ]);
        if (e) throw e;
        var evt = this._getEvent(id);
        if (!evt || (evt.length === 0)) return null;
        evt = Array.clone(evt);
        return function(source, args) {
            for (var i = 0, l = evt.length; i < l; i++) {
                evt[i](source, args);
            }
        };
    }
    function Sys$EventHandlerList$_getEvent(id, create) {
        if (!this._list[id]) {
            if (!create) return null;
            this._list[id] = [];
        }
        return this._list[id];
    }
Sys.EventHandlerList.prototype = {
    _addHandler: Sys$EventHandlerList$_addHandler,
    addHandler: Sys$EventHandlerList$addHandler,
    _removeHandler: Sys$EventHandlerList$_removeHandler,
    removeHandler: Sys$EventHandlerList$removeHandler,
    getHandler: Sys$EventHandlerList$getHandler,
    _getEvent: Sys$EventHandlerList$_getEvent
}
Sys.EventHandlerList.registerClass('Sys.EventHandlerList');
Sys.CommandEventArgs = function Sys$CommandEventArgs(commandName, commandArgument, commandSource) {
    /// <summary locid="M:J#Sys.CommandEventArgs.#ctor" />
    /// <param name="commandName" type="String"></param>
    /// <param name="commandArgument" mayBeNull="true"></param>
    /// <param name="commandSource" mayBeNull="true"></param>
    var e = Function._validateParams(arguments, [
        {name: "commandName", type: String},
        {name: "commandArgument", mayBeNull: true},
        {name: "commandSource", mayBeNull: true}
    ]);
    if (e) throw e;
    Sys.CommandEventArgs.initializeBase(this);
    this._commandName = commandName;
    this._commandArgument = commandArgument;
    this._commandSource = commandSource;
}
    function Sys$CommandEventArgs$get_commandName() {
        /// <value type="String" locid="P:J#Sys.CommandEventArgs.commandName"></value>
        if (arguments.length !== 0) throw Error.parameterCount();
        return this._commandName;
    }
    function Sys$CommandEventArgs$get_commandArgument() {
        /// <value mayBeNull="true" locid="P:J#Sys.CommandEventArgs.commandArgument"></value>
        if (arguments.length !== 0) throw Error.parameterCount();
        return this._commandArgument;
    }
    function Sys$CommandEventArgs$get_commandSource() {
        /// <value mayBeNull="true" locid="P:J#Sys.CommandEventArgs.commandSource"></value>
        if (arguments.length !== 0) throw Error.parameterCount();
        return this._commandSource;
    }
Sys.CommandEventArgs.prototype = {
    _commandName: null,
    _commandArgument: null,
    _commandSource: null,
    get_commandName: Sys$CommandEventArgs$get_commandName,
    get_commandArgument: Sys$CommandEventArgs$get_commandArgument,
    get_commandSource: Sys$CommandEventArgs$get_commandSource
}
Sys.CommandEventArgs.registerClass("Sys.CommandEventArgs", Sys.CancelEventArgs);
 
Sys.INotifyPropertyChange = function Sys$INotifyPropertyChange() {
    /// <summary locid="M:J#Sys.INotifyPropertyChange.#ctor" />
    if (arguments.length !== 0) throw Error.parameterCount();
    throw Error.notImplemented();
}
    function Sys$INotifyPropertyChange$add_propertyChanged(handler) {
    /// <summary locid="E:J#Sys.INotifyPropertyChange.propertyChanged" />
    var e = Function._validateParams(arguments, [{name: "handler", type: Function}]);
    if (e) throw e;
        throw Error.notImplemented();
    }
    function Sys$INotifyPropertyChange$remove_propertyChanged(handler) {
    var e = Function._validateParams(arguments, [{name: "handler", type: Function}]);
    if (e) throw e;
        throw Error.notImplemented();
    }
Sys.INotifyPropertyChange.prototype = {
    add_propertyChanged: Sys$INotifyPropertyChange$add_propertyChanged,
    remove_propertyChanged: Sys$INotifyPropertyChange$remove_propertyChanged
}
Sys.INotifyPropertyChange.registerInterface('Sys.INotifyPropertyChange');
 
Sys.PropertyChangedEventArgs = function Sys$PropertyChangedEventArgs(propertyName) {
    /// <summary locid="M:J#Sys.PropertyChangedEventArgs.#ctor" />
    /// <param name="propertyName" type="String"></param>
    var e = Function._validateParams(arguments, [
        {name: "propertyName", type: String}
    ]);
    if (e) throw e;
    Sys.PropertyChangedEventArgs.initializeBase(this);
    this._propertyName = propertyName;
}
 
    function Sys$PropertyChangedEventArgs$get_propertyName() {
        /// <value type="String" locid="P:J#Sys.PropertyChangedEventArgs.propertyName"></value>
        if (arguments.length !== 0) throw Error.parameterCount();
        return this._propertyName;
    }
Sys.PropertyChangedEventArgs.prototype = {
    get_propertyName: Sys$PropertyChangedEventArgs$get_propertyName
}
Sys.PropertyChangedEventArgs.registerClass('Sys.PropertyChangedEventArgs', Sys.EventArgs);
 
Sys.INotifyDisposing = function Sys$INotifyDisposing() {
    /// <summary locid="M:J#Sys.INotifyDisposing.#ctor" />
    if (arguments.length !== 0) throw Error.parameterCount();
    throw Error.notImplemented();
}
    function Sys$INotifyDisposing$add_disposing(handler) {
    /// <summary locid="E:J#Sys.INotifyDisposing.disposing" />
    var e = Function._validateParams(arguments, [{name: "handler", type: Function}]);
    if (e) throw e;
        throw Error.notImplemented();
    }
    function Sys$INotifyDisposing$remove_disposing(handler) {
    var e = Function._validateParams(arguments, [{name: "handler", type: Function}]);
    if (e) throw e;
        throw Error.notImplemented();
    }
Sys.INotifyDisposing.prototype = {
    add_disposing: Sys$INotifyDisposing$add_disposing,
    remove_disposing: Sys$INotifyDisposing$remove_disposing
}
Sys.INotifyDisposing.registerInterface("Sys.INotifyDisposing");
 
Sys.Component = function Sys$Component() {
    /// <summary locid="M:J#Sys.Component.#ctor" />
    if (arguments.length !== 0) throw Error.parameterCount();
    if (Sys.Application) Sys.Application.registerDisposableObject(this);
}
    function Sys$Component$get_events() {
        /// <value type="Sys.EventHandlerList" locid="P:J#Sys.Component.events"></value>
        if (arguments.length !== 0) throw Error.parameterCount();
        if (!this._events) {
            this._events = new Sys.EventHandlerList();
        }
        return this._events;
    }
    function Sys$Component$get_id() {
        /// <value type="String" locid="P:J#Sys.Component.id"></value>
        if (arguments.length !== 0) throw Error.parameterCount();
        return this._id;
    }
    function Sys$Component$set_id(value) {
        var e = Function._validateParams(arguments, [{name: "value", type: String}]);
        if (e) throw e;
        if (this._idSet) throw Error.invalidOperation(Sys.Res.componentCantSetIdTwice);
        this._idSet = true;
        var oldId = this.get_id();
        if (oldId && Sys.Application.findComponent(oldId)) throw Error.invalidOperation(Sys.Res.componentCantSetIdAfterAddedToApp);
        this._id = value;
    }
    function Sys$Component$get_isInitialized() {
        /// <value type="Boolean" locid="P:J#Sys.Component.isInitialized"></value>
        if (arguments.length !== 0) throw Error.parameterCount();
        return this._initialized;
    }
    function Sys$Component$get_isUpdating() {
        /// <value type="Boolean" locid="P:J#Sys.Component.isUpdating"></value>
        if (arguments.length !== 0) throw Error.parameterCount();
        return this._updating;
    }
    function Sys$Component$add_disposing(handler) {
        /// <summary locid="E:J#Sys.Component.disposing" />
        var e = Function._validateParams(arguments, [{name: "handler", type: Function}]);
        if (e) throw e;
        this.get_events().addHandler("disposing", handler);
    }
    function Sys$Component$remove_disposing(handler) {
        var e = Function._validateParams(arguments, [{name: "handler", type: Function}]);
        if (e) throw e;
        this.get_events().removeHandler("disposing", handler);
    }
    function Sys$Component$add_propertyChanged(handler) {
        /// <summary locid="E:J#Sys.Component.propertyChanged" />
        var e = Function._validateParams(arguments, [{name: "handler", type: Function}]);
        if (e) throw e;
        this.get_events().addHandler("propertyChanged", handler);
    }
    function Sys$Component$remove_propertyChanged(handler) {
        var e = Function._validateParams(arguments, [{name: "handler", type: Function}]);
        if (e) throw e;
        this.get_events().removeHandler("propertyChanged", handler);
    }
    function Sys$Component$beginUpdate() {
        this._updating = true;
    }
    function Sys$Component$dispose() {
        if (this._events) {
            var handler = this._events.getHandler("disposing");
            if (handler) {
                handler(this, Sys.EventArgs.Empty);
            }
        }
        delete this._events;
        Sys.Application.unregisterDisposableObject(this);
        Sys.Application.removeComponent(this);
    }
    function Sys$Component$endUpdate() {
        this._updating = false;
        if (!this._initialized) this.initialize();
        this.updated();
    }
    function Sys$Component$initialize() {
        this._initialized = true;
    }
    function Sys$Component$raisePropertyChanged(propertyName) {
        /// <summary locid="M:J#Sys.Component.raisePropertyChanged" />
        /// <param name="propertyName" type="String"></param>
        var e = Function._validateParams(arguments, [
            {name: "propertyName", type: String}
        ]);
        if (e) throw e;
        if (!this._events) return;
        var handler = this._events.getHandler("propertyChanged");
        if (handler) {
            handler(this, new Sys.PropertyChangedEventArgs(propertyName));
        }
    }
    function Sys$Component$updated() {
    }
Sys.Component.prototype = {
    _id: null,
    _idSet: false,
    _initialized: false,
    _updating: false,
    get_events: Sys$Component$get_events,
    get_id: Sys$Component$get_id,
    set_id: Sys$Component$set_id,
    get_isInitialized: Sys$Component$get_isInitialized,
    get_isUpdating: Sys$Component$get_isUpdating,
    add_disposing: Sys$Component$add_disposing,
    remove_disposing: Sys$Component$remove_disposing,
    add_propertyChanged: Sys$Component$add_propertyChanged,
    remove_propertyChanged: Sys$Component$remove_propertyChanged,
    beginUpdate: Sys$Component$beginUpdate,
    dispose: Sys$Component$dispose,
    endUpdate: Sys$Component$endUpdate,
    initialize: Sys$Component$initialize,
    raisePropertyChanged: Sys$Component$raisePropertyChanged,
    updated: Sys$Component$updated
}
Sys.Component.registerClass('Sys.Component', null, Sys.IDisposable, Sys.INotifyPropertyChange, Sys.INotifyDisposing);
function Sys$Component$_setProperties(target, properties) {
    /// <summary locid="M:J#Sys.Component._setProperties" />
    /// <param name="target"></param>
    /// <param name="properties"></param>
    var e = Function._validateParams(arguments, [
        {name: "target"},
        {name: "properties"}
    ]);
    if (e) throw e;
    var current;
    var targetType = Object.getType(target);
    var isObject = (targetType === Object) || (targetType === Sys.UI.DomElement);
    var isComponent = Sys.Component.isInstanceOfType(target) && !target.get_isUpdating();
    if (isComponent) target.beginUpdate();
    for (var name in properties) {
        var val = properties[name];
        var getter = isObject ? null : target["get_" + name];
        if (isObject || typeof(getter) !== 'function') {
            var targetVal = target[name];
            if (!isObject && typeof(targetVal) === 'undefined') throw Error.invalidOperation(String.format(Sys.Res.propertyUndefined, name));
            if (!val || (typeof(val) !== 'object') || (isObject && !targetVal)) {
                target[name] = val;
            }
            else {
                Sys$Component$_setProperties(targetVal, val);
            }
        }
        else {
            var setter = target["set_" + name];
            if (typeof(setter) === 'function') {
                setter.apply(target, [val]);
            }
            else if (val instanceof Array) {
                current = getter.apply(target);
                if (!(current instanceof Array)) throw new Error.invalidOperation(String.format(Sys.Res.propertyNotAnArray, name));
                for (var i = 0, j = current.length, l= val.length; i < l; i++, j++) {
                    current[j] = val[i];
                }
            }
            else if ((typeof(val) === 'object') && (Object.getType(val) === Object)) {
                current = getter.apply(target);
                if ((typeof(current) === 'undefined') || (current === null)) throw new Error.invalidOperation(String.format(Sys.Res.propertyNullOrUndefined, name));
                Sys$Component$_setProperties(current, val);
            }
            else {
                throw new Error.invalidOperation(String.format(Sys.Res.propertyNotWritable, name));
            }
        }
    }
    if (isComponent) target.endUpdate();
}
function Sys$Component$_setReferences(component, references) {
    for (var name in references) {
        var setter = component["set_" + name];
        var reference = $find(references[name]);
        if (typeof(setter) !== 'function') throw new Error.invalidOperation(String.format(Sys.Res.propertyNotWritable, name));
        if (!reference) throw Error.invalidOperation(String.format(Sys.Res.referenceNotFound, references[name]));
        setter.apply(component, [reference]);
    }
}
var $create = Sys.Component.create = function Sys$Component$create(type, properties, events, references, element) {
    /// <summary locid="M:J#Sys.Component.create" />
    /// <param name="type" type="Type"></param>
    /// <param name="properties" optional="true" mayBeNull="true"></param>
    /// <param name="events" optional="true" mayBeNull="true"></param>
    /// <param name="references" optional="true" mayBeNull="true"></param>
    /// <param name="element" domElement="true" optional="true" mayBeNull="true"></param>
    /// <returns type="Sys.UI.Component"></returns>
    var e = Function._validateParams(arguments, [
        {name: "type", type: Type},
        {name: "properties", mayBeNull: true, optional: true},
        {name: "events", mayBeNull: true, optional: true},
        {name: "references", mayBeNull: true, optional: true},
        {name: "element", mayBeNull: true, domElement: true, optional: true}
    ]);
    if (e) throw e;
    if (!type.inheritsFrom(Sys.Component)) {
        throw Error.argument('type', String.format(Sys.Res.createNotComponent, type.getName()));
    }
    if (type.inheritsFrom(Sys.UI.Behavior) || type.inheritsFrom(Sys.UI.Control)) {
        if (!element) throw Error.argument('element', Sys.Res.createNoDom);
    }
    else if (element) throw Error.argument('element', Sys.Res.createComponentOnDom);
    var component = (element ? new type(element): new type());
    var app = Sys.Application;
    var creatingComponents = app.get_isCreatingComponents();
    component.beginUpdate();
    if (properties) {
        Sys$Component$_setProperties(component, properties);
    }
    if (events) {
        for (var name in events) {
            if (!(component["add_" + name] instanceof Function)) throw new Error.invalidOperation(String.format(Sys.Res.undefinedEvent, name));
            if (!(events[name] instanceof Function)) throw new Error.invalidOperation(Sys.Res.eventHandlerNotFunction);
            component["add_" + name](events[name]);
        }
    }
    if (component.get_id()) {
        app.addComponent(component);
    }
    if (creatingComponents) {
        app._createdComponents[app._createdComponents.length] = component;
        if (references) {
            app._addComponentToSecondPass(component, references);
        }
        else {
            component.endUpdate();
        }
    }
    else {
        if (references) {
            Sys$Component$_setReferences(component, references);
        }
        component.endUpdate();
    }
    return component;
}
 
Sys.UI.MouseButton = function Sys$UI$MouseButton() {
    /// <summary locid="M:J#Sys.UI.MouseButton.#ctor" />
    /// <field name="leftButton" type="Number" integer="true" static="true" locid="F:J#Sys.UI.MouseButton.leftButton"></field>
    /// <field name="middleButton" type="Number" integer="true" static="true" locid="F:J#Sys.UI.MouseButton.middleButton"></field>
    /// <field name="rightButton" type="Number" integer="true" static="true" locid="F:J#Sys.UI.MouseButton.rightButton"></field>
    if (arguments.length !== 0) throw Error.parameterCount();
    throw Error.notImplemented();
}
Sys.UI.MouseButton.prototype = {
    leftButton: 0,
    middleButton: 1,
    rightButton: 2
}
Sys.UI.MouseButton.registerEnum("Sys.UI.MouseButton");
 
Sys.UI.Key = function Sys$UI$Key() {
    /// <summary locid="M:J#Sys.UI.Key.#ctor" />
    /// <field name="backspace" type="Number" integer="true" static="true" locid="F:J#Sys.UI.Key.backspace"></field>
    /// <field name="tab" type="Number" integer="true" static="true" locid="F:J#Sys.UI.Key.tab"></field>
    /// <field name="enter" type="Number" integer="true" static="true" locid="F:J#Sys.UI.Key.enter"></field>
    /// <field name="esc" type="Number" integer="true" static="true" locid="F:J#Sys.UI.Key.esc"></field>
    /// <field name="space" type="Number" integer="true" static="true" locid="F:J#Sys.UI.Key.space"></field>
    /// <field name="pageUp" type="Number" integer="true" static="true" locid="F:J#Sys.UI.Key.pageUp"></field>
    /// <field name="pageDown" type="Number" integer="true" static="true" locid="F:J#Sys.UI.Key.pageDown"></field>
    /// <field name="end" type="Number" integer="true" static="true" locid="F:J#Sys.UI.Key.end"></field>
    /// <field name="home" type="Number" integer="true" static="true" locid="F:J#Sys.UI.Key.home"></field>
    /// <field name="left" type="Number" integer="true" static="true" locid="F:J#Sys.UI.Key.left"></field>
    /// <field name="up" type="Number" integer="true" static="true" locid="F:J#Sys.UI.Key.up"></field>
    /// <field name="right" type="Number" integer="true" static="true" locid="F:J#Sys.UI.Key.right"></field>
    /// <field name="down" type="Number" integer="true" static="true" locid="F:J#Sys.UI.Key.down"></field>
    /// <field name="del" type="Number" integer="true" static="true" locid="F:J#Sys.UI.Key.del"></field>
    if (arguments.length !== 0) throw Error.parameterCount();
    throw Error.notImplemented();
}
Sys.UI.Key.prototype = {
    backspace: 8,
    tab: 9,
    enter: 13,
    esc: 27,
    space: 32,
    pageUp: 33,
    pageDown: 34,
    end: 35,
    home: 36,
    left: 37,
    up: 38,
    right: 39,
    down: 40,
    del: 127
}
Sys.UI.Key.registerEnum("Sys.UI.Key");
 
Sys.UI.Point = function Sys$UI$Point(x, y) {
    /// <summary locid="M:J#Sys.UI.Point.#ctor" />
    /// <param name="x" type="Number"></param>
    /// <param name="y" type="Number"></param>
    /// <field name="x" type="Number" integer="true" locid="F:J#Sys.UI.Point.x"></field>
    /// <field name="y" type="Number" integer="true" locid="F:J#Sys.UI.Point.y"></field>
    /// <field name="rawX" type="Number" locid="F:J#Sys.UI.Point.rawX"></field>
    /// <field name="rawY" type="Number" locid="F:J#Sys.UI.Point.rawY"></field>
    var e = Function._validateParams(arguments, [
        {name: "x", type: Number},
        {name: "y", type: Number}
    ]);
    if (e) throw e;
    this.rawX = x;
    this.rawY = y;
    this.x = Math.round(x);
    this.y = Math.round(y);
}
Sys.UI.Point.registerClass('Sys.UI.Point');
 
Sys.UI.Bounds = function Sys$UI$Bounds(x, y, width, height) {
    /// <summary locid="M:J#Sys.UI.Bounds.#ctor" />
    /// <param name="x" type="Number" integer="true"></param>
    /// <param name="y" type="Number" integer="true"></param>
    /// <param name="width" type="Number" integer="true"></param>
    /// <param name="height" type="Number" integer="true"></param>
    /// <field name="x" type="Number" integer="true" locid="F:J#Sys.UI.Bounds.x"></field>
    /// <field name="y" type="Number" integer="true" locid="F:J#Sys.UI.Bounds.y"></field>
    /// <field name="width" type="Number" integer="true" locid="F:J#Sys.UI.Bounds.width"></field>
    /// <field name="height" type="Number" integer="true" locid="F:J#Sys.UI.Bounds.height"></field>
    var e = Function._validateParams(arguments, [
        {name: "x", type: Number, integer: true},
        {name: "y", type: Number, integer: true},
        {name: "width", type: Number, integer: true},
        {name: "height", type: Number, integer: true}
    ]);
    if (e) throw e;
    this.x = x;
    this.y = y;
    this.height = height;
    this.width = width;
}
Sys.UI.Bounds.registerClass('Sys.UI.Bounds');
 
Sys.UI.DomEvent = function Sys$UI$DomEvent(eventObject) {
    /// <summary locid="M:J#Sys.UI.DomEvent.#ctor" />
    /// <param name="eventObject"></param>
    /// <field name="altKey" type="Boolean" locid="F:J#Sys.UI.DomEvent.altKey"></field>
    /// <field name="button" type="Sys.UI.MouseButton" locid="F:J#Sys.UI.DomEvent.button"></field>
    /// <field name="charCode" type="Number" integer="true" locid="F:J#Sys.UI.DomEvent.charCode"></field>
    /// <field name="clientX" type="Number" integer="true" locid="F:J#Sys.UI.DomEvent.clientX"></field>
    /// <field name="clientY" type="Number" integer="true" locid="F:J#Sys.UI.DomEvent.clientY"></field>
    /// <field name="ctrlKey" type="Boolean" locid="F:J#Sys.UI.DomEvent.ctrlKey"></field>
    /// <field name="keyCode" type="Number" integer="true" locid="F:J#Sys.UI.DomEvent.keyCode"></field>
    /// <field name="offsetX" type="Number" integer="true" locid="F:J#Sys.UI.DomEvent.offsetX"></field>
    /// <field name="offsetY" type="Number" integer="true" locid="F:J#Sys.UI.DomEvent.offsetY"></field>
    /// <field name="screenX" type="Number" integer="true" locid="F:J#Sys.UI.DomEvent.screenX"></field>
    /// <field name="screenY" type="Number" integer="true" locid="F:J#Sys.UI.DomEvent.screenY"></field>
    /// <field name="shiftKey" type="Boolean" locid="F:J#Sys.UI.DomEvent.shiftKey"></field>
    /// <field name="target" locid="F:J#Sys.UI.DomEvent.target"></field>
    /// <field name="type" type="String" locid="F:J#Sys.UI.DomEvent.type"></field>
    var e = Function._validateParams(arguments, [
        {name: "eventObject"}
    ]);
    if (e) throw e;
    var ev = eventObject;
    var etype = this.type = ev.type.toLowerCase();
    this.rawEvent = ev;
    this.altKey = ev.altKey;
    if (typeof(ev.button) !== 'undefined') {
        this.button = (typeof(ev.which) !== 'undefined') ? ev.button :
            (ev.button === 4) ? Sys.UI.MouseButton.middleButton :
            (ev.button === 2) ? Sys.UI.MouseButton.rightButton :
            Sys.UI.MouseButton.leftButton;
    }
    if (etype === 'keypress') {
        this.charCode = ev.charCode || ev.keyCode;
    }
    else if (ev.keyCode && (ev.keyCode === 46)) {
        this.keyCode = 127;
    }
    else {
        this.keyCode = ev.keyCode;
    }
    this.clientX = ev.clientX;
    this.clientY = ev.clientY;
    this.ctrlKey = ev.ctrlKey;
    this.target = ev.target ? ev.target : ev.srcElement;
    if (!etype.startsWith('key')) {
        if ((typeof(ev.offsetX) !== 'undefined') && (typeof(ev.offsetY) !== 'undefined')) {
            this.offsetX = ev.offsetX;
            this.offsetY = ev.offsetY;
        }
        else if (this.target && (this.target.nodeType !== 3) && (typeof(ev.clientX) === 'number')) {
            var loc = Sys.UI.DomElement.getLocation(this.target);
            var w = Sys.UI.DomElement._getWindow(this.target);
            this.offsetX = (w.pageXOffset || 0) + ev.clientX - loc.x;
            this.offsetY = (w.pageYOffset || 0) + ev.clientY - loc.y;
        }
    }
    this.screenX = ev.screenX;
    this.screenY = ev.screenY;
    this.shiftKey = ev.shiftKey;
}
    function Sys$UI$DomEvent$preventDefault() {
        /// <summary locid="M:J#Sys.UI.DomEvent.preventDefault" />
        if (arguments.length !== 0) throw Error.parameterCount();
        if (this.rawEvent.preventDefault) {
            this.rawEvent.preventDefault();
        }
        else if (window.event) {
            this.rawEvent.returnValue = false;
        }
    }
    function Sys$UI$DomEvent$stopPropagation() {
        /// <summary locid="M:J#Sys.UI.DomEvent.stopPropagation" />
        if (arguments.length !== 0) throw Error.parameterCount();
        if (this.rawEvent.stopPropagation) {
            this.rawEvent.stopPropagation();
        }
        else if (window.event) {
            this.rawEvent.cancelBubble = true;
        }
    }
Sys.UI.DomEvent.prototype = {
    preventDefault: Sys$UI$DomEvent$preventDefault,
    stopPropagation: Sys$UI$DomEvent$stopPropagation
}
Sys.UI.DomEvent.registerClass('Sys.UI.DomEvent');
var $addHandler = Sys.UI.DomEvent.addHandler = function Sys$UI$DomEvent$addHandler(element, eventName, handler, autoRemove) {
    /// <summary locid="M:J#Sys.UI.DomEvent.addHandler" />
    /// <param name="element"></param>
    /// <param name="eventName" type="String"></param>
    /// <param name="handler" type="Function"></param>
    /// <param name="autoRemove" type="Boolean" optional="true"></param>
    var e = Function._validateParams(arguments, [
        {name: "element"},
        {name: "eventName", type: String},
        {name: "handler", type: Function},
        {name: "autoRemove", type: Boolean, optional: true}
    ]);
    if (e) throw e;
    Sys.UI.DomEvent._ensureDomNode(element);
    if (eventName === "error") throw Error.invalidOperation(Sys.Res.addHandlerCantBeUsedForError);
    if (!element._events) {
        element._events = {};
    }
    var eventCache = element._events[eventName];
    if (!eventCache) {
        element._events[eventName] = eventCache = [];
    }
    var browserHandler;
    if (element.addEventListener) {
        browserHandler = function(e) {
            return handler.call(element, new Sys.UI.DomEvent(e));
        }
        element.addEventListener(eventName, browserHandler, false);
    }
    else if (element.attachEvent) {
        browserHandler = function() {
            var e = {};
            try {e = Sys.UI.DomElement._getWindow(element).event} catch(ex) {}
            return handler.call(element, new Sys.UI.DomEvent(e));
        }
        element.attachEvent('on' + eventName, browserHandler);
    }
    eventCache[eventCache.length] = {handler: handler, browserHandler: browserHandler, autoRemove: autoRemove };
    if (autoRemove) {
        var d = element.dispose;
        if (d !== Sys.UI.DomEvent._disposeHandlers) {
            element.dispose = Sys.UI.DomEvent._disposeHandlers;
            if (typeof(d) !== "undefined") {
                element._chainDispose = d;
            }
        }
    }
}
var $addHandlers = Sys.UI.DomEvent.addHandlers = function Sys$UI$DomEvent$addHandlers(element, events, handlerOwner, autoRemove) {
    /// <summary locid="M:J#Sys.UI.DomEvent.addHandlers" />
    /// <param name="element"></param>
    /// <param name="events" type="Object"></param>
    /// <param name="handlerOwner" optional="true"></param>
    /// <param name="autoRemove" type="Boolean" optional="true"></param>
    var e = Function._validateParams(arguments, [
        {name: "element"},
        {name: "events", type: Object},
        {name: "handlerOwner", optional: true},
        {name: "autoRemove", type: Boolean, optional: true}
    ]);
    if (e) throw e;
    Sys.UI.DomEvent._ensureDomNode(element);
    for (var name in events) {
        var handler = events[name];
        if (typeof(handler) !== 'function') throw Error.invalidOperation(Sys.Res.cantAddNonFunctionhandler);
        if (handlerOwner) {
            handler = Function.createDelegate(handlerOwner, handler);
        }
        $addHandler(element, name, handler, autoRemove || false);
    }
}
var $clearHandlers = Sys.UI.DomEvent.clearHandlers = function Sys$UI$DomEvent$clearHandlers(element) {
    /// <summary locid="M:J#Sys.UI.DomEvent.clearHandlers" />
    /// <param name="element"></param>
    var e = Function._validateParams(arguments, [
        {name: "element"}
    ]);
    if (e) throw e;
    Sys.UI.DomEvent._ensureDomNode(element);
    Sys.UI.DomEvent._clearHandlers(element, false);
}
Sys.UI.DomEvent._clearHandlers = function Sys$UI$DomEvent$_clearHandlers(element, autoRemoving) {
    if (element._events) {
        var cache = element._events;
        for (var name in cache) {
            var handlers = cache[name];
            for (var i = handlers.length - 1; i >= 0; i--) {
                var entry = handlers[i];
                if (!autoRemoving || entry.autoRemove) {
                    $removeHandler(element, name, entry.handler);
                }
            }
        }
        element._events = null;
    }
}
Sys.UI.DomEvent._disposeHandlers = function Sys$UI$DomEvent$_disposeHandlers() {
    Sys.UI.DomEvent._clearHandlers(this, true);
    var d = this._chainDispose, type = typeof(d);
    if (type !== "undefined") {
        this.dispose = d;
        this._chainDispose = null;
        if (type === "function") {
            this.dispose();
        }
    }
}
var $removeHandler = Sys.UI.DomEvent.removeHandler = function Sys$UI$DomEvent$removeHandler(element, eventName, handler) {
    /// <summary locid="M:J#Sys.UI.DomEvent.removeHandler" />
    /// <param name="element"></param>
    /// <param name="eventName" type="String"></param>
    /// <param name="handler" type="Function"></param>
    var e = Function._validateParams(arguments, [
        {name: "element"},
        {name: "eventName", type: String},
        {name: "handler", type: Function}
    ]);
    if (e) throw e;
    Sys.UI.DomEvent._removeHandler(element, eventName, handler);
}
Sys.UI.DomEvent._removeHandler = function Sys$UI$DomEvent$_removeHandler(element, eventName, handler) {
    Sys.UI.DomEvent._ensureDomNode(element);
    var browserHandler = null;
    if ((typeof(element._events) !== 'object') || !element._events) throw Error.invalidOperation(Sys.Res.eventHandlerInvalid);
    var cache = element._events[eventName];
    if (!(cache instanceof Array)) throw Error.invalidOperation(Sys.Res.eventHandlerInvalid);
    for (var i = 0, l = cache.length; i < l; i++) {
        if (cache[i].handler === handler) {
            browserHandler = cache[i].browserHandler;
            break;
        }
    }
    if (typeof(browserHandler) !== 'function') throw Error.invalidOperation(Sys.Res.eventHandlerInvalid);
    if (element.removeEventListener) {
        element.removeEventListener(eventName, browserHandler, false);
    }
    else if (element.detachEvent) {
        element.detachEvent('on' + eventName, browserHandler);
    }
    cache.splice(i, 1);
}
Sys.UI.DomEvent._ensureDomNode = function Sys$UI$DomEvent$_ensureDomNode(element) {
    if (element.tagName && (element.tagName.toUpperCase() === "SCRIPT")) return;
    
    var doc = element.ownerDocument || element.document || element;
    if ((typeof(element.document) !== 'object') && (element != doc) && (typeof(element.nodeType) !== 'number')) {
        throw Error.argument("element", Sys.Res.argumentDomNode);
    }
}
 
Sys.UI.DomElement = function Sys$UI$DomElement() {
    /// <summary locid="M:J#Sys.UI.DomElement.#ctor" />
    if (arguments.length !== 0) throw Error.parameterCount();
    throw Error.notImplemented();
}
Sys.UI.DomElement.registerClass('Sys.UI.DomElement');
Sys.UI.DomElement.addCssClass = function Sys$UI$DomElement$addCssClass(element, className) {
    /// <summary locid="M:J#Sys.UI.DomElement.addCssClass" />
    /// <param name="element" domElement="true"></param>
    /// <param name="className" type="String"></param>
    var e = Function._validateParams(arguments, [
        {name: "element", domElement: true},
        {name: "className", type: String}
    ]);
    if (e) throw e;
    if (!Sys.UI.DomElement.containsCssClass(element, className)) {
        if (element.className === '') {
            element.className = className;
        }
        else {
            element.className += ' ' + className;
        }
    }
}
Sys.UI.DomElement.containsCssClass = function Sys$UI$DomElement$containsCssClass(element, className) {
    /// <summary locid="M:J#Sys.UI.DomElement.containsCssClass" />
    /// <param name="element" domElement="true"></param>
    /// <param name="className" type="String"></param>
    /// <returns type="Boolean"></returns>
    var e = Function._validateParams(arguments, [
        {name: "element", domElement: true},
        {name: "className", type: String}
    ]);
    if (e) throw e;
    return Array.contains(element.className.split(' '), className);
}
Sys.UI.DomElement.getBounds = function Sys$UI$DomElement$getBounds(element) {
    /// <summary locid="M:J#Sys.UI.DomElement.getBounds" />
    /// <param name="element" domElement="true"></param>
    /// <returns type="Sys.UI.Bounds"></returns>
    var e = Function._validateParams(arguments, [
        {name: "element", domElement: true}
    ]);
    if (e) throw e;
    var offset = Sys.UI.DomElement.getLocation(element);
    return new Sys.UI.Bounds(offset.x, offset.y, element.offsetWidth || 0, element.offsetHeight || 0);
}
var $get = Sys.UI.DomElement.getElementById = function Sys$UI$DomElement$getElementById(id, element) {
    /// <summary locid="M:J#Sys.UI.DomElement.getElementById" />
    /// <param name="id" type="String"></param>
    /// <param name="element" domElement="true" optional="true" mayBeNull="true"></param>
    /// <returns domElement="true" mayBeNull="true"></returns>
    var e = Function._validateParams(arguments, [
        {name: "id", type: String},
        {name: "element", mayBeNull: true, domElement: true, optional: true}
    ]);
    if (e) throw e;
    if (!element) return document.getElementById(id);
    if (element.getElementById) return element.getElementById(id);
    var nodeQueue = [];
    var childNodes = element.childNodes;
    for (var i = 0; i < childNodes.length; i++) {
        var node = childNodes[i];
        if (node.nodeType == 1) {
            nodeQueue[nodeQueue.length] = node;
        }
    }
    while (nodeQueue.length) {
        node = nodeQueue.shift();
        if (node.id == id) {
            return node;
        }
        childNodes = node.childNodes;
        for (i = 0; i < childNodes.length; i++) {
            node = childNodes[i];
            if (node.nodeType == 1) {
                nodeQueue[nodeQueue.length] = node;
            }
        }
    }
    return null;
}
if (document.documentElement.getBoundingClientRect) {
    Sys.UI.DomElement.getLocation = function Sys$UI$DomElement$getLocation(element) {
        /// <summary locid="M:J#Sys.UI.DomElement.getLocation" />
        /// <param name="element" domElement="true"></param>
        /// <returns type="Sys.UI.Point"></returns>
        var e = Function._validateParams(arguments, [
            {name: "element", domElement: true}
        ]);
        if (e) throw e;
        if (element.self || element.nodeType === 9 || 
            (element === document.documentElement) || 
            (element.parentNode === element.ownerDocument.documentElement)) { 
            return new Sys.UI.Point(0, 0);
        }        
        
        var clientRect = element.getBoundingClientRect();
        if (!clientRect) {
            return new Sys.UI.Point(0,0);
        }
        var documentElement = element.ownerDocument.documentElement;
        var bodyElement = element.ownerDocument.body;
        var ex,
            offsetX = Math.round(clientRect.left) + (documentElement.scrollLeft || bodyElement.scrollLeft),
            offsetY = Math.round(clientRect.top) + (documentElement.scrollTop || bodyElement.scrollTop);
        if (Sys.Browser.agent === Sys.Browser.InternetExplorer) {
            try {
                var f = element.ownerDocument.parentWindow.frameElement || null;
                if (f) {
                    var offset = (f.frameBorder === "0" || f.frameBorder === "no") ? 2 : 0;
                    offsetX += offset;
                    offsetY += offset;
                }
            }
            catch(ex) {
            }
            if (Sys.Browser.version === 7 && !document.documentMode) {
                var body = document.body,
                    rect = body.getBoundingClientRect(),
                    zoom = (rect.right-rect.left) / body.clientWidth;
                zoom = Math.round(zoom * 100);
                zoom = (zoom - zoom % 5) / 100;
                if (!isNaN(zoom) && (zoom !== 1)) {
                    offsetX = Math.round(offsetX / zoom);
                    offsetY = Math.round(offsetY / zoom);
                }
            }        
            if ((document.documentMode || 0) < 8) {
                offsetX -= documentElement.clientLeft;
                offsetY -= documentElement.clientTop;
            }
        }
        return new Sys.UI.Point(offsetX, offsetY);
    }
}
else if (Sys.Browser.agent === Sys.Browser.Safari) {
    Sys.UI.DomElement.getLocation = function Sys$UI$DomElement$getLocation(element) {
        /// <summary locid="M:J#Sys.UI.DomElement.getLocation" />
        /// <param name="element" domElement="true"></param>
        /// <returns type="Sys.UI.Point"></returns>
        var e = Function._validateParams(arguments, [
            {name: "element", domElement: true}
        ]);
        if (e) throw e;
        if ((element.window && (element.window === element)) || element.nodeType === 9) return new Sys.UI.Point(0,0);
        var offsetX = 0, offsetY = 0,
            parent,
            previous = null,
            previousStyle = null,
            currentStyle;
        for (parent = element; parent; previous = parent, previousStyle = currentStyle, parent = parent.offsetParent) {
            currentStyle = Sys.UI.DomElement._getCurrentStyle(parent);
            var tagName = parent.tagName ? parent.tagName.toUpperCase() : null;
            if ((parent.offsetLeft || parent.offsetTop) &&
                ((tagName !== "BODY") || (!previousStyle || previousStyle.position !== "absolute"))) {
                offsetX += parent.offsetLeft;
                offsetY += parent.offsetTop;
            }
            if (previous && Sys.Browser.version >= 3) {
                offsetX += parseInt(currentStyle.borderLeftWidth);
                offsetY += parseInt(currentStyle.borderTopWidth);
            }
        }
        currentStyle = Sys.UI.DomElement._getCurrentStyle(element);
        var elementPosition = currentStyle ? currentStyle.position : null;
        if (!elementPosition || (elementPosition !== "absolute")) {
            for (parent = element.parentNode; parent; parent = parent.parentNode) {
                tagName = parent.tagName ? parent.tagName.toUpperCase() : null;
                if ((tagName !== "BODY") && (tagName !== "HTML") && (parent.scrollLeft || parent.scrollTop)) {
                    offsetX -= (parent.scrollLeft || 0);
                    offsetY -= (parent.scrollTop || 0);
                }
                currentStyle = Sys.UI.DomElement._getCurrentStyle(parent);
                var parentPosition = currentStyle ? currentStyle.position : null;
                if (parentPosition && (parentPosition === "absolute")) break;
            }
        }
        return new Sys.UI.Point(offsetX, offsetY);
    }
}
else {
    Sys.UI.DomElement.getLocation = function Sys$UI$DomElement$getLocation(element) {
        /// <summary locid="M:J#Sys.UI.DomElement.getLocation" />
        /// <param name="element" domElement="true"></param>
        /// <returns type="Sys.UI.Point"></returns>
        var e = Function._validateParams(arguments, [
            {name: "element", domElement: true}
        ]);
        if (e) throw e;
        if ((element.window && (element.window === element)) || element.nodeType === 9) return new Sys.UI.Point(0,0);
        var offsetX = 0, offsetY = 0,
            parent,
            previous = null,
            previousStyle = null,
            currentStyle = null;
        for (parent = element; parent; previous = parent, previousStyle = currentStyle, parent = parent.offsetParent) {
            var tagName = parent.tagName ? parent.tagName.toUpperCase() : null;
            currentStyle = Sys.UI.DomElement._getCurrentStyle(parent);
            if ((parent.offsetLeft || parent.offsetTop) &&
                !((tagName === "BODY") &&
                (!previousStyle || previousStyle.position !== "absolute"))) {
                offsetX += parent.offsetLeft;
                offsetY += parent.offsetTop;
            }
            if (previous !== null && currentStyle) {
                if ((tagName !== "TABLE") && (tagName !== "TD") && (tagName !== "HTML")) {
                    offsetX += parseInt(currentStyle.borderLeftWidth) || 0;
                    offsetY += parseInt(currentStyle.borderTopWidth) || 0;
                }
                if (tagName === "TABLE" &&
                    (currentStyle.position === "relative" || currentStyle.position === "absolute")) {
                    offsetX += parseInt(currentStyle.marginLeft) || 0;
                    offsetY += parseInt(currentStyle.marginTop) || 0;
                }
            }
        }
        currentStyle = Sys.UI.DomElement._getCurrentStyle(element);
        var elementPosition = currentStyle ? currentStyle.position : null;
        if (!elementPosition || (elementPosition !== "absolute")) {
            for (parent = element.parentNode; parent; parent = parent.parentNode) {
                tagName = parent.tagName ? parent.tagName.toUpperCase() : null;
                if ((tagName !== "BODY") && (tagName !== "HTML") && (parent.scrollLeft || parent.scrollTop)) {
                    offsetX -= (parent.scrollLeft || 0);
                    offsetY -= (parent.scrollTop || 0);
                    currentStyle = Sys.UI.DomElement._getCurrentStyle(parent);
                    if (currentStyle) {
                        offsetX += parseInt(currentStyle.borderLeftWidth) || 0;
                        offsetY += parseInt(currentStyle.borderTopWidth) || 0;
                    }
                }
            }
        }
        return new Sys.UI.Point(offsetX, offsetY);
    }
}
Sys.UI.DomElement.isDomElement = function Sys$UI$DomElement$isDomElement(obj) {
    /// <summary locid="M:J#Sys.UI.DomElement.isDomElement" />
    /// <param name="obj"></param>
    /// <returns type="Boolean"></returns>
    var e = Function._validateParams(arguments, [
        {name: "obj"}
    ]);
    if (e) throw e;
    return Sys._isDomElement(obj);
}
Sys.UI.DomElement.removeCssClass = function Sys$UI$DomElement$removeCssClass(element, className) {
    /// <summary locid="M:J#Sys.UI.DomElement.removeCssClass" />
    /// <param name="element" domElement="true"></param>
    /// <param name="className" type="String"></param>
    var e = Function._validateParams(arguments, [
        {name: "element", domElement: true},
        {name: "className", type: String}
    ]);
    if (e) throw e;
    var currentClassName = ' ' + element.className + ' ';
    var index = currentClassName.indexOf(' ' + className + ' ');
    if (index >= 0) {
        element.className = (currentClassName.substr(0, index) + ' ' +
            currentClassName.substring(index + className.length + 1, currentClassName.length)).trim();
    }
}
Sys.UI.DomElement.resolveElement = function Sys$UI$DomElement$resolveElement(elementOrElementId, containerElement) {
    /// <summary locid="M:J#Sys.UI.DomElement.resolveElement" />
    /// <param name="elementOrElementId" mayBeNull="true"></param>
    /// <param name="containerElement" domElement="true" optional="true" mayBeNull="true"></param>
    /// <returns domElement="true"></returns>
    var e = Function._validateParams(arguments, [
        {name: "elementOrElementId", mayBeNull: true},
        {name: "containerElement", mayBeNull: true, domElement: true, optional: true}
    ]);
    if (e) throw e;
    var el = elementOrElementId;
    if (!el) return null;
    if (typeof(el) === "string") {
        el = Sys.UI.DomElement.getElementById(el, containerElement);
        if (!el) {
            throw Error.argument("elementOrElementId", String.format(Sys.Res.elementNotFound, elementOrElementId));
        }
    }
    else if(!Sys.UI.DomElement.isDomElement(el)) {
        throw Error.argument("elementOrElementId", Sys.Res.expectedElementOrId);
    }
    return el;
}
Sys.UI.DomElement.raiseBubbleEvent = function Sys$UI$DomElement$raiseBubbleEvent(source, args) {
    /// <summary locid="M:J#Sys.UI.DomElement.raiseBubbleEvent" />
    /// <param name="source" domElement="true"></param>
    /// <param name="args" type="Sys.EventArgs"></param>
    var e = Function._validateParams(arguments, [
        {name: "source", domElement: true},
        {name: "args", type: Sys.EventArgs}
    ]);
    if (e) throw e;
    var target = source;
    while (target) {
        var control = target.control;
        if (control && control.onBubbleEvent && control.raiseBubbleEvent) {
            Sys.UI.DomElement._raiseBubbleEventFromControl(control, source, args);
            return;
        }
        target = target.parentNode;
    }
}
Sys.UI.DomElement._raiseBubbleEventFromControl = function Sys$UI$DomElement$_raiseBubbleEventFromControl(control, source, args) {
    if (!control.onBubbleEvent(source, args)) {
        control._raiseBubbleEvent(source, args);
    }
}
Sys.UI.DomElement.setLocation = function Sys$UI$DomElement$setLocation(element, x, y) {
    /// <summary locid="M:J#Sys.UI.DomElement.setLocation" />
    /// <param name="element" domElement="true"></param>
    /// <param name="x" type="Number" integer="true"></param>
    /// <param name="y" type="Number" integer="true"></param>
    var e = Function._validateParams(arguments, [
        {name: "element", domElement: true},
        {name: "x", type: Number, integer: true},
        {name: "y", type: Number, integer: true}
    ]);
    if (e) throw e;
    var style = element.style;
    style.position = 'absolute';
    style.left = x + "px";
    style.top = y + "px";
}
Sys.UI.DomElement.toggleCssClass = function Sys$UI$DomElement$toggleCssClass(element, className) {
    /// <summary locid="M:J#Sys.UI.DomElement.toggleCssClass" />
    /// <param name="element" domElement="true"></param>
    /// <param name="className" type="String"></param>
    var e = Function._validateParams(arguments, [
        {name: "element", domElement: true},
        {name: "className", type: String}
    ]);
    if (e) throw e;
    if (Sys.UI.DomElement.containsCssClass(element, className)) {
        Sys.UI.DomElement.removeCssClass(element, className);
    }
    else {
        Sys.UI.DomElement.addCssClass(element, className);
    }
}
Sys.UI.DomElement.getVisibilityMode = function Sys$UI$DomElement$getVisibilityMode(element) {
    /// <summary locid="M:J#Sys.UI.DomElement.getVisibilityMode" />
    /// <param name="element" domElement="true"></param>
    /// <returns type="Sys.UI.VisibilityMode"></returns>
    var e = Function._validateParams(arguments, [
        {name: "element", domElement: true}
    ]);
    if (e) throw e;
    return (element._visibilityMode === Sys.UI.VisibilityMode.hide) ?
        Sys.UI.VisibilityMode.hide :
        Sys.UI.VisibilityMode.collapse;
}
Sys.UI.DomElement.setVisibilityMode = function Sys$UI$DomElement$setVisibilityMode(element, value) {
    /// <summary locid="M:J#Sys.UI.DomElement.setVisibilityMode" />
    /// <param name="element" domElement="true"></param>
    /// <param name="value" type="Sys.UI.VisibilityMode"></param>
    var e = Function._validateParams(arguments, [
        {name: "element", domElement: true},
        {name: "value", type: Sys.UI.VisibilityMode}
    ]);
    if (e) throw e;
    Sys.UI.DomElement._ensureOldDisplayMode(element);
    if (element._visibilityMode !== value) {
        element._visibilityMode = value;
        if (Sys.UI.DomElement.getVisible(element) === false) {
            if (element._visibilityMode === Sys.UI.VisibilityMode.hide) {
                element.style.display = element._oldDisplayMode;
            }
            else {
                element.style.display = 'none';
            }
        }
        element._visibilityMode = value;
    }
}
Sys.UI.DomElement.getVisible = function Sys$UI$DomElement$getVisible(element) {
    /// <summary locid="M:J#Sys.UI.DomElement.getVisible" />
    /// <param name="element" domElement="true"></param>
    /// <returns type="Boolean"></returns>
    var e = Function._validateParams(arguments, [
        {name: "element", domElement: true}
    ]);
    if (e) throw e;
    var style = element.currentStyle || Sys.UI.DomElement._getCurrentStyle(element);
    if (!style) return true;
    return (style.visibility !== 'hidden') && (style.display !== 'none');
}
Sys.UI.DomElement.setVisible = function Sys$UI$DomElement$setVisible(element, value) {
    /// <summary locid="M:J#Sys.UI.DomElement.setVisible" />
    /// <param name="element" domElement="true"></param>
    /// <param name="value" type="Boolean"></param>
    var e = Function._validateParams(arguments, [
        {name: "element", domElement: true},
        {name: "value", type: Boolean}
    ]);
    if (e) throw e;
    if (value !== Sys.UI.DomElement.getVisible(element)) {
        Sys.UI.DomElement._ensureOldDisplayMode(element);
        element.style.visibility = value ? 'visible' : 'hidden';
        if (value || (element._visibilityMode === Sys.UI.VisibilityMode.hide)) {
            element.style.display = element._oldDisplayMode;
        }
        else {
            element.style.display = 'none';
        }
    }
}
Sys.UI.DomElement._ensureOldDisplayMode = function Sys$UI$DomElement$_ensureOldDisplayMode(element) {
    if (!element._oldDisplayMode) {
        var style = element.currentStyle || Sys.UI.DomElement._getCurrentStyle(element);
        element._oldDisplayMode = style ? style.display : null;
        if (!element._oldDisplayMode || element._oldDisplayMode === 'none') {
            switch(element.tagName.toUpperCase()) {
                case 'DIV': case 'P': case 'ADDRESS': case 'BLOCKQUOTE': case 'BODY': case 'COL':
                case 'COLGROUP': case 'DD': case 'DL': case 'DT': case 'FIELDSET': case 'FORM':
                case 'H1': case 'H2': case 'H3': case 'H4': case 'H5': case 'H6': case 'HR':
                case 'IFRAME': case 'LEGEND': case 'OL': case 'PRE': case 'TABLE': case 'TD':
                case 'TH': case 'TR': case 'UL':
                    element._oldDisplayMode = 'block';
                    break;
                case 'LI':
                    element._oldDisplayMode = 'list-item';
                    break;
                default:
                    element._oldDisplayMode = 'inline';
            }
        }
    }
}
Sys.UI.DomElement._getWindow = function Sys$UI$DomElement$_getWindow(element) {
    var doc = element.ownerDocument || element.document || element;
    return doc.defaultView || doc.parentWindow;
}
Sys.UI.DomElement._getCurrentStyle = function Sys$UI$DomElement$_getCurrentStyle(element) {
    if (element.nodeType === 3) return null;
    var w = Sys.UI.DomElement._getWindow(element);
    if (element.documentElement) element = element.documentElement;
    var computedStyle = (w && (element !== w) && w.getComputedStyle) ?
        w.getComputedStyle(element, null) :
        element.currentStyle || element.style;
    if (!computedStyle && (Sys.Browser.agent === Sys.Browser.Safari) && element.style) {
        var oldDisplay = element.style.display;
        var oldPosition = element.style.position;
        element.style.position = 'absolute';
        element.style.display = 'block';
        var style = w.getComputedStyle(element, null);
        element.style.display = oldDisplay;
        element.style.position = oldPosition;
        computedStyle = {};
        for (var n in style) {
            computedStyle[n] = style[n];
        }
        computedStyle.display = 'none';
    }
    return computedStyle;
}
 
Sys.IContainer = function Sys$IContainer() {
    throw Error.notImplemented();
}
    function Sys$IContainer$addComponent(component) {
        /// <summary locid="M:J#Sys.IContainer.addComponent" />
        /// <param name="component" type="Sys.Component"></param>
        var e = Function._validateParams(arguments, [
            {name: "component", type: Sys.Component}
        ]);
        if (e) throw e;
        throw Error.notImplemented();
    }
    function Sys$IContainer$removeComponent(component) {
        /// <summary locid="M:J#Sys.IContainer.removeComponent" />
        /// <param name="component" type="Sys.Component"></param>
        var e = Function._validateParams(arguments, [
            {name: "component", type: Sys.Component}
        ]);
        if (e) throw e;
        throw Error.notImplemented();
    }
    function Sys$IContainer$findComponent(id) {
        /// <summary locid="M:J#Sys.IContainer.findComponent" />
        /// <param name="id" type="String"></param>
        /// <returns type="Sys.Component"></returns>
        var e = Function._validateParams(arguments, [
            {name: "id", type: String}
        ]);
        if (e) throw e;
        throw Error.notImplemented();
    }
    function Sys$IContainer$getComponents() {
        /// <summary locid="M:J#Sys.IContainer.getComponents" />
        /// <returns type="Array" elementType="Sys.Component"></returns>
        if (arguments.length !== 0) throw Error.parameterCount();
        throw Error.notImplemented();
    }
Sys.IContainer.prototype = {
    addComponent: Sys$IContainer$addComponent,
    removeComponent: Sys$IContainer$removeComponent,
    findComponent: Sys$IContainer$findComponent,
    getComponents: Sys$IContainer$getComponents
}
Sys.IContainer.registerInterface("Sys.IContainer");
 
Sys.ApplicationLoadEventArgs = function Sys$ApplicationLoadEventArgs(components, isPartialLoad) {
    /// <summary locid="M:J#Sys.ApplicationLoadEventArgs.#ctor" />
    /// <param name="components" type="Array" elementType="Sys.Component"></param>
    /// <param name="isPartialLoad" type="Boolean"></param>
    var e = Function._validateParams(arguments, [
        {name: "components", type: Array, elementType: Sys.Component},
        {name: "isPartialLoad", type: Boolean}
    ]);
    if (e) throw e;
    Sys.ApplicationLoadEventArgs.initializeBase(this);
    this._components = components;
    this._isPartialLoad = isPartialLoad;
}
 
    function Sys$ApplicationLoadEventArgs$get_components() {
        /// <value type="Array" elementType="Sys.Component" locid="P:J#Sys.ApplicationLoadEventArgs.components"></value>
        if (arguments.length !== 0) throw Error.parameterCount();
        return this._components;
    }
    function Sys$ApplicationLoadEventArgs$get_isPartialLoad() {
        /// <value type="Boolean" locid="P:J#Sys.ApplicationLoadEventArgs.isPartialLoad"></value>
        if (arguments.length !== 0) throw Error.parameterCount();
        return this._isPartialLoad;
    }
Sys.ApplicationLoadEventArgs.prototype = {
    get_components: Sys$ApplicationLoadEventArgs$get_components,
    get_isPartialLoad: Sys$ApplicationLoadEventArgs$get_isPartialLoad
}
Sys.ApplicationLoadEventArgs.registerClass('Sys.ApplicationLoadEventArgs', Sys.EventArgs);
 
Sys._Application = function Sys$_Application() {
    /// <summary locid="M:J#Sys.Application.#ctor" />
    if (arguments.length !== 0) throw Error.parameterCount();
    Sys._Application.initializeBase(this);
    this._disposableObjects = [];
    this._components = {};
    this._createdComponents = [];
    this._secondPassComponents = [];
    this._unloadHandlerDelegate = Function.createDelegate(this, this._unloadHandler);
    Sys.UI.DomEvent.addHandler(window, "unload", this._unloadHandlerDelegate);
    this._domReady();
}
    function Sys$_Application$get_isCreatingComponents() {
        /// <value type="Boolean" locid="P:J#Sys.Application.isCreatingComponents"></value>
        if (arguments.length !== 0) throw Error.parameterCount();
        return this._creatingComponents;
    }
    function Sys$_Application$get_isDisposing() {
        /// <value type="Boolean" locid="P:J#Sys.Application.isDisposing"></value>
        if (arguments.length !== 0) throw Error.parameterCount();
        return this._disposing;
    }
    function Sys$_Application$add_init(handler) {
        /// <summary locid="E:J#Sys.Application.init" />
        var e = Function._validateParams(arguments, [{name: "handler", type: Function}]);
        if (e) throw e;
        if (this._initialized) {
            handler(this, Sys.EventArgs.Empty);
        }
        else {
            this.get_events().addHandler("init", handler);
        }
    }
    function Sys$_Application$remove_init(handler) {
        var e = Function._validateParams(arguments, [{name: "handler", type: Function}]);
        if (e) throw e;
        this.get_events().removeHandler("init", handler);
    }
    function Sys$_Application$add_load(handler) {
        /// <summary locid="E:J#Sys.Application.load" />
        var e = Function._validateParams(arguments, [{name: "handler", type: Function}]);
        if (e) throw e;
        this.get_events().addHandler("load", handler);
    }
    function Sys$_Application$remove_load(handler) {
        var e = Function._validateParams(arguments, [{name: "handler", type: Function}]);
        if (e) throw e;
        this.get_events().removeHandler("load", handler);
    }
    function Sys$_Application$add_unload(handler) {
        /// <summary locid="E:J#Sys.Application.unload" />
        var e = Function._validateParams(arguments, [{name: "handler", type: Function}]);
        if (e) throw e;
        this.get_events().addHandler("unload", handler);
    }
    function Sys$_Application$remove_unload(handler) {
        var e = Function._validateParams(arguments, [{name: "handler", type: Function}]);
        if (e) throw e;
        this.get_events().removeHandler("unload", handler);
    }
    function Sys$_Application$addComponent(component) {
        /// <summary locid="M:J#Sys.Application.addComponent" />
        /// <param name="component" type="Sys.Component"></param>
        var e = Function._validateParams(arguments, [
            {name: "component", type: Sys.Component}
        ]);
        if (e) throw e;
        var id = component.get_id();
        if (!id) throw Error.invalidOperation(Sys.Res.cantAddWithoutId);
        if (typeof(this._components[id]) !== 'undefined') throw Error.invalidOperation(String.format(Sys.Res.appDuplicateComponent, id));
        this._components[id] = component;
    }
    function Sys$_Application$beginCreateComponents() {
        /// <summary locid="M:J#Sys.Application.beginCreateComponents" />
        if (arguments.length !== 0) throw Error.parameterCount();
        this._creatingComponents = true;
    }
    function Sys$_Application$dispose() {
        /// <summary locid="M:J#Sys.Application.dispose" />
        if (arguments.length !== 0) throw Error.parameterCount();
        if (!this._disposing) {
            this._disposing = true;
            if (this._timerCookie) {
                window.clearTimeout(this._timerCookie);
                delete this._timerCookie;
            }
            if (this._endRequestHandler) {
                Sys.WebForms.PageRequestManager.getInstance().remove_endRequest(this._endRequestHandler);
                delete this._endRequestHandler;
            }
            if (this._beginRequestHandler) {
                Sys.WebForms.PageRequestManager.getInstance().remove_beginRequest(this._beginRequestHandler);
                delete this._beginRequestHandler;
            }
            if (window.pageUnload) {
                window.pageUnload(this, Sys.EventArgs.Empty);
            }
            var unloadHandler = this.get_events().getHandler("unload");
            if (unloadHandler) {
                unloadHandler(this, Sys.EventArgs.Empty);
            }
            var disposableObjects = Array.clone(this._disposableObjects);
            for (var i = 0, l = disposableObjects.length; i < l; i++) {
                var object = disposableObjects[i];
                if (typeof(object) !== "undefined") {
                    object.dispose();
                }
            }
            Array.clear(this._disposableObjects);
            Sys.UI.DomEvent.removeHandler(window, "unload", this._unloadHandlerDelegate);
            if (Sys._ScriptLoader) {
                var sl = Sys._ScriptLoader.getInstance();
                if(sl) {
                    sl.dispose();
                }
            }
            Sys._Application.callBaseMethod(this, 'dispose');
        }
    }
    function Sys$_Application$disposeElement(element, childNodesOnly) {
        /// <summary locid="M:J#Sys._Application.disposeElement" />
        /// <param name="element"></param>
        /// <param name="childNodesOnly" type="Boolean"></param>
        var e = Function._validateParams(arguments, [
            {name: "element"},
            {name: "childNodesOnly", type: Boolean}
        ]);
        if (e) throw e;
        if (element.nodeType === 1) {
            var i, allElements = element.getElementsByTagName("*"),
                length = allElements.length,
                children = new Array(length);
            for (i = 0; i < length; i++) {
                children[i] = allElements[i];
            }
            for (i = length - 1; i >= 0; i--) {
                var child = children[i];
                var d = child.dispose;
                if (d && typeof(d) === "function") {
                    child.dispose();
                }
                else {
                    var c = child.control;
                    if (c && typeof(c.dispose) === "function") {
                        c.dispose();
                    }
                }
                var list = child._behaviors;
                if (list) {
                    this._disposeComponents(list);
                }
                list = child._components;
                if (list) {
                    this._disposeComponents(list);
                    child._components = null;
                }
            }
            if (!childNodesOnly) {
                var d = element.dispose;
                if (d && typeof(d) === "function") {
                    element.dispose();
                }
                else {
                    var c = element.control;
                    if (c && typeof(c.dispose) === "function") {
                        c.dispose();
                    }
                }
                var list = element._behaviors;
                if (list) {
                    this._disposeComponents(list);
                }
                list = element._components;
                if (list) {
                    this._disposeComponents(list);
                    element._components = null;
                }
            }
        }
    }
    function Sys$_Application$endCreateComponents() {
        /// <summary locid="M:J#Sys.Application.endCreateComponents" />
        if (arguments.length !== 0) throw Error.parameterCount();
        var components = this._secondPassComponents;
        for (var i = 0, l = components.length; i < l; i++) {
            var component = components[i].component;
            Sys$Component$_setReferences(component, components[i].references);
            component.endUpdate();
        }
        this._secondPassComponents = [];
        this._creatingComponents = false;
    }
    function Sys$_Application$findComponent(id, parent) {
        /// <summary locid="M:J#Sys.Application.findComponent" />
        /// <param name="id" type="String"></param>
        /// <param name="parent" optional="true" mayBeNull="true"></param>
        /// <returns type="Sys.Component" mayBeNull="true"></returns>
        var e = Function._validateParams(arguments, [
            {name: "id", type: String},
            {name: "parent", mayBeNull: true, optional: true}
        ]);
        if (e) throw e;
        return (parent ?
            ((Sys.IContainer.isInstanceOfType(parent)) ?
                parent.findComponent(id) :
                parent[id] || null) :
            Sys.Application._components[id] || null);
    }
    function Sys$_Application$getComponents() {
        /// <summary locid="M:J#Sys.Application.getComponents" />
        /// <returns type="Array" elementType="Sys.Component"></returns>
        if (arguments.length !== 0) throw Error.parameterCount();
        var res = [];
        var components = this._components;
        for (var name in components) {
            res[res.length] = components[name];
        }
        return res;
    }
    function Sys$_Application$initialize() {
        /// <summary locid="M:J#Sys.Application.initialize" />
        if (arguments.length !== 0) throw Error.parameterCount();
        if(!this.get_isInitialized() && !this._disposing) {
            Sys._Application.callBaseMethod(this, 'initialize');
            this._raiseInit();
            if (this.get_stateString) {
                if (Sys.WebForms && Sys.WebForms.PageRequestManager) {
                    this._beginRequestHandler = Function.createDelegate(this, this._onPageRequestManagerBeginRequest);
                    Sys.WebForms.PageRequestManager.getInstance().add_beginRequest(this._beginRequestHandler);
                    this._endRequestHandler = Function.createDelegate(this, this._onPageRequestManagerEndRequest);
                    Sys.WebForms.PageRequestManager.getInstance().add_endRequest(this._endRequestHandler);
                }
                var loadedEntry = this.get_stateString();
                if (loadedEntry !== this._currentEntry) {
                    this._navigate(loadedEntry);
                }
                else {
                    this._ensureHistory();
                }
            }
            this.raiseLoad();
        }
    }
    function Sys$_Application$notifyScriptLoaded() {
        /// <summary locid="M:J#Sys.Application.notifyScriptLoaded" />
        if (arguments.length !== 0) throw Error.parameterCount();
    }
    function Sys$_Application$registerDisposableObject(object) {
        /// <summary locid="M:J#Sys.Application.registerDisposableObject" />
        /// <param name="object" type="Sys.IDisposable"></param>
        var e = Function._validateParams(arguments, [
            {name: "object", type: Sys.IDisposable}
        ]);
        if (e) throw e;
        if (!this._disposing) {
            var objects = this._disposableObjects,
                i = objects.length;
            objects[i] = object;
            object.__msdisposeindex = i;
        }
    }
    function Sys$_Application$raiseLoad() {
        /// <summary locid="M:J#Sys.Application.raiseLoad" />
        if (arguments.length !== 0) throw Error.parameterCount();
        var h = this.get_events().getHandler("load");
        var args = new Sys.ApplicationLoadEventArgs(Array.clone(this._createdComponents), !!this._loaded);
        this._loaded = true;
        if (h) {
            h(this, args);
        }
        if (window.pageLoad) {
            window.pageLoad(this, args);
        }
        this._createdComponents = [];
    }
    function Sys$_Application$removeComponent(component) {
        /// <summary locid="M:J#Sys.Application.removeComponent" />
        /// <param name="component" type="Sys.Component"></param>
        var e = Function._validateParams(arguments, [
            {name: "component", type: Sys.Component}
        ]);
        if (e) throw e;
        var id = component.get_id();
        if (id) delete this._components[id];
    }
    function Sys$_Application$unregisterDisposableObject(object) {
        /// <summary locid="M:J#Sys.Application.unregisterDisposableObject" />
        /// <param name="object" type="Sys.IDisposable"></param>
        var e = Function._validateParams(arguments, [
            {name: "object", type: Sys.IDisposable}
        ]);
        if (e) throw e;
        if (!this._disposing) {
            var i = object.__msdisposeindex;
            if (typeof(i) === "number") {
                var disposableObjects = this._disposableObjects;
                delete disposableObjects[i];
                delete object.__msdisposeindex;
                if (++this._deleteCount > 1000) {
                    var newArray = [];
                    for (var j = 0, l = disposableObjects.length; j < l; j++) {
                        object = disposableObjects[j];
                        if (typeof(object) !== "undefined") {
                            object.__msdisposeindex = newArray.length;
                            newArray.push(object);
                        }
                    }
                    this._disposableObjects = newArray;
                    this._deleteCount = 0;
                }
            }
        }
    }
    function Sys$_Application$_addComponentToSecondPass(component, references) {
        this._secondPassComponents[this._secondPassComponents.length] = {component: component, references: references};
    }
    function Sys$_Application$_disposeComponents(list) {
        if (list) {
            for (var i = list.length - 1; i >= 0; i--) {
                var item = list[i];
                if (typeof(item.dispose) === "function") {
                    item.dispose();
                }
            }
        }
    }
    function Sys$_Application$_domReady() {
        var check, er, app = this;
        function init() { app.initialize(); }
        var onload = function() {
            Sys.UI.DomEvent.removeHandler(window, "load", onload);
            init();
        }
        Sys.UI.DomEvent.addHandler(window, "load", onload);
        
        if (document.addEventListener) {
            try {
                document.addEventListener("DOMContentLoaded", check = function() {
                    document.removeEventListener("DOMContentLoaded", check, false);
                    init();
                }, false);
            }
            catch (er) { }
        }
        else if (document.attachEvent) {
            if ((window == window.top) && document.documentElement.doScroll) {
                var timeout, el = document.createElement("div");
                check = function() {
                    try {
                        el.doScroll("left");
                    }
                    catch (er) {
                        timeout = window.setTimeout(check, 0);
                        return;
                    }
                    el = null;
                    init();
                }
                check();
            }
            else {
		document.attachEvent("onreadystatechange", check = function() {
                    if (document.readyState === "complete") {
                        document.detachEvent("onreadystatechange", check);
                        init();
                    }
                });
            }
        }
    }
    function Sys$_Application$_raiseInit() {
        var handler = this.get_events().getHandler("init");
        if (handler) {
            this.beginCreateComponents();
            handler(this, Sys.EventArgs.Empty);
            this.endCreateComponents();
        }
    }
    function Sys$_Application$_unloadHandler(event) {
        this.dispose();
    }
Sys._Application.prototype = {
    _creatingComponents: false,
    _disposing: false,
    _deleteCount: 0,
    get_isCreatingComponents: Sys$_Application$get_isCreatingComponents,
    get_isDisposing: Sys$_Application$get_isDisposing,
    add_init: Sys$_Application$add_init,
    remove_init: Sys$_Application$remove_init,
    add_load: Sys$_Application$add_load,
    remove_load: Sys$_Application$remove_load,
    add_unload: Sys$_Application$add_unload,
    remove_unload: Sys$_Application$remove_unload,
    addComponent: Sys$_Application$addComponent,
    beginCreateComponents: Sys$_Application$beginCreateComponents,
    dispose: Sys$_Application$dispose,
    disposeElement: Sys$_Application$disposeElement,
    endCreateComponents: Sys$_Application$endCreateComponents,
    findComponent: Sys$_Application$findComponent,
    getComponents: Sys$_Application$getComponents,
    initialize: Sys$_Application$initialize,
    notifyScriptLoaded: Sys$_Application$notifyScriptLoaded,
    registerDisposableObject: Sys$_Application$registerDisposableObject,
    raiseLoad: Sys$_Application$raiseLoad,
    removeComponent: Sys$_Application$removeComponent,
    unregisterDisposableObject: Sys$_Application$unregisterDisposableObject,
    _addComponentToSecondPass: Sys$_Application$_addComponentToSecondPass,
    _disposeComponents: Sys$_Application$_disposeComponents,
    _domReady: Sys$_Application$_domReady,
    _raiseInit: Sys$_Application$_raiseInit,
    _unloadHandler: Sys$_Application$_unloadHandler
}
Sys._Application.registerClass('Sys._Application', Sys.Component, Sys.IContainer);
Sys.Application = new Sys._Application();
var $find = Sys.Application.findComponent;
 
Sys.UI.Behavior = function Sys$UI$Behavior(element) {
    /// <summary locid="M:J#Sys.UI.Behavior.#ctor" />
    /// <param name="element" domElement="true"></param>
    var e = Function._validateParams(arguments, [
        {name: "element", domElement: true}
    ]);
    if (e) throw e;
    Sys.UI.Behavior.initializeBase(this);
    this._element = element;
    var behaviors = element._behaviors;
    if (!behaviors) {
        element._behaviors = [this];
    }
    else {
        behaviors[behaviors.length] = this;
    }
}
    function Sys$UI$Behavior$get_element() {
        /// <value domElement="true" locid="P:J#Sys.UI.Behavior.element"></value>
        if (arguments.length !== 0) throw Error.parameterCount();
        return this._element;
    }
    function Sys$UI$Behavior$get_id() {
        /// <value type="String" locid="P:J#Sys.UI.Behavior.id"></value>
        if (arguments.length !== 0) throw Error.parameterCount();
        var baseId = Sys.UI.Behavior.callBaseMethod(this, 'get_id');
        if (baseId) return baseId;
        if (!this._element || !this._element.id) return '';
        return this._element.id + '$' + this.get_name();
    }
    function Sys$UI$Behavior$get_name() {
        /// <value type="String" locid="P:J#Sys.UI.Behavior.name"></value>
        if (arguments.length !== 0) throw Error.parameterCount();
        if (this._name) return this._name;
        var name = Object.getTypeName(this);
        var i = name.lastIndexOf('.');
        if (i !== -1) name = name.substr(i + 1);
        if (!this.get_isInitialized()) this._name = name;
        return name;
    }
    function Sys$UI$Behavior$set_name(value) {
        var e = Function._validateParams(arguments, [{name: "value", type: String}]);
        if (e) throw e;
        if ((value === '') || (value.charAt(0) === ' ') || (value.charAt(value.length - 1) === ' '))
            throw Error.argument('value', Sys.Res.invalidId);
        if (typeof(this._element[value]) !== 'undefined')
            throw Error.invalidOperation(String.format(Sys.Res.behaviorDuplicateName, value));
        if (this.get_isInitialized()) throw Error.invalidOperation(Sys.Res.cantSetNameAfterInit);
        this._name = value;
    }
    function Sys$UI$Behavior$initialize() {
        Sys.UI.Behavior.callBaseMethod(this, 'initialize');
        var name = this.get_name();
        if (name) this._element[name] = this;
    }
    function Sys$UI$Behavior$dispose() {
        Sys.UI.Behavior.callBaseMethod(this, 'dispose');
        var e = this._element;
        if (e) {
            var name = this.get_name();
            if (name) {
                e[name] = null;
            }
            var behaviors = e._behaviors;
            Array.remove(behaviors, this);
            if (behaviors.length === 0) {
                e._behaviors = null;
            }
            delete this._element;
        }
    }
Sys.UI.Behavior.prototype = {
    _name: null,
    get_element: Sys$UI$Behavior$get_element,
    get_id: Sys$UI$Behavior$get_id,
    get_name: Sys$UI$Behavior$get_name,
    set_name: Sys$UI$Behavior$set_name,
    initialize: Sys$UI$Behavior$initialize,
    dispose: Sys$UI$Behavior$dispose
}
Sys.UI.Behavior.registerClass('Sys.UI.Behavior', Sys.Component);
Sys.UI.Behavior.getBehaviorByName = function Sys$UI$Behavior$getBehaviorByName(element, name) {
    /// <summary locid="M:J#Sys.UI.Behavior.getBehaviorByName" />
    /// <param name="element" domElement="true"></param>
    /// <param name="name" type="String"></param>
    /// <returns type="Sys.UI.Behavior" mayBeNull="true"></returns>
    var e = Function._validateParams(arguments, [
        {name: "element", domElement: true},
        {name: "name", type: String}
    ]);
    if (e) throw e;
    var b = element[name];
    return (b && Sys.UI.Behavior.isInstanceOfType(b)) ? b : null;
}
Sys.UI.Behavior.getBehaviors = function Sys$UI$Behavior$getBehaviors(element) {
    /// <summary locid="M:J#Sys.UI.Behavior.getBehaviors" />
    /// <param name="element" domElement="true"></param>
    /// <returns type="Array" elementType="Sys.UI.Behavior"></returns>
    var e = Function._validateParams(arguments, [
        {name: "element", domElement: true}
    ]);
    if (e) throw e;
    if (!element._behaviors) return [];
    return Array.clone(element._behaviors);
}
Sys.UI.Behavior.getBehaviorsByType = function Sys$UI$Behavior$getBehaviorsByType(element, type) {
    /// <summary locid="M:J#Sys.UI.Behavior.getBehaviorsByType" />
    /// <param name="element" domElement="true"></param>
    /// <param name="type" type="Type"></param>
    /// <returns type="Array" elementType="Sys.UI.Behavior"></returns>
    var e = Function._validateParams(arguments, [
        {name: "element", domElement: true},
        {name: "type", type: Type}
    ]);
    if (e) throw e;
    var behaviors = element._behaviors;
    var results = [];
    if (behaviors) {
        for (var i = 0, l = behaviors.length; i < l; i++) {
            if (type.isInstanceOfType(behaviors[i])) {
                results[results.length] = behaviors[i];
            }
        }
    }
    return results;
}
 
Sys.UI.VisibilityMode = function Sys$UI$VisibilityMode() {
    /// <summary locid="M:J#Sys.UI.VisibilityMode.#ctor" />
    /// <field name="hide" type="Number" integer="true" static="true" locid="F:J#Sys.UI.VisibilityMode.hide"></field>
    /// <field name="collapse" type="Number" integer="true" static="true" locid="F:J#Sys.UI.VisibilityMode.collapse"></field>
    if (arguments.length !== 0) throw Error.parameterCount();
    throw Error.notImplemented();
}
Sys.UI.VisibilityMode.prototype = {
    hide: 0,
    collapse: 1
}
Sys.UI.VisibilityMode.registerEnum("Sys.UI.VisibilityMode");
 
Sys.UI.Control = function Sys$UI$Control(element) {
    /// <summary locid="M:J#Sys.UI.Control.#ctor" />
    /// <param name="element" domElement="true"></param>
    var e = Function._validateParams(arguments, [
        {name: "element", domElement: true}
    ]);
    if (e) throw e;
    if (element.control !== null && typeof(element.control) !== 'undefined') throw Error.invalidOperation(Sys.Res.controlAlreadyDefined);
    Sys.UI.Control.initializeBase(this);
    this._element = element;
    element.control = this;
    var role = this.get_role();
    if (role) {
        element.setAttribute("role", role);
    }
}
    function Sys$UI$Control$get_element() {
        /// <value domElement="true" locid="P:J#Sys.UI.Control.element"></value>
        if (arguments.length !== 0) throw Error.parameterCount();
        return this._element;
    }
    function Sys$UI$Control$get_id() {
        /// <value type="String" locid="P:J#Sys.UI.Control.id"></value>
        if (arguments.length !== 0) throw Error.parameterCount();
        if (!this._element) return '';
        return this._element.id;
    }
    function Sys$UI$Control$set_id(value) {
        var e = Function._validateParams(arguments, [{name: "value", type: String}]);
        if (e) throw e;
        throw Error.invalidOperation(Sys.Res.cantSetId);
    }
    function Sys$UI$Control$get_parent() {
        /// <value type="Sys.UI.Control" locid="P:J#Sys.UI.Control.parent"></value>
        if (arguments.length !== 0) throw Error.parameterCount();
        if (this._parent) return this._parent;
        if (!this._element) return null;
        
        var parentElement = this._element.parentNode;
        while (parentElement) {
            if (parentElement.control) {
                return parentElement.control;
            }
            parentElement = parentElement.parentNode;
        }
        return null;
    }
    function Sys$UI$Control$set_parent(value) {
        var e = Function._validateParams(arguments, [{name: "value", type: Sys.UI.Control}]);
        if (e) throw e;
        if (!this._element) throw Error.invalidOperation(Sys.Res.cantBeCalledAfterDispose);
        var parents = [this];
        var current = value;
        while (current) {
            if (Array.contains(parents, current)) throw Error.invalidOperation(Sys.Res.circularParentChain);
            parents[parents.length] = current;
            current = current.get_parent();
        }
        this._parent = value;
    }
    function Sys$UI$Control$get_role() {
        /// <value type="String" locid="P:J#Sys.UI.Control.role"></value>
        if (arguments.length !== 0) throw Error.parameterCount();
        return null;
    }
    function Sys$UI$Control$get_visibilityMode() {
        /// <value type="Sys.UI.VisibilityMode" locid="P:J#Sys.UI.Control.visibilityMode"></value>
        if (arguments.length !== 0) throw Error.parameterCount();
        if (!this._element) throw Error.invalidOperation(Sys.Res.cantBeCalledAfterDispose);
        return Sys.UI.DomElement.getVisibilityMode(this._element);
    }
    function Sys$UI$Control$set_visibilityMode(value) {
        var e = Function._validateParams(arguments, [{name: "value", type: Sys.UI.VisibilityMode}]);
        if (e) throw e;
        if (!this._element) throw Error.invalidOperation(Sys.Res.cantBeCalledAfterDispose);
        Sys.UI.DomElement.setVisibilityMode(this._element, value);
    }
    function Sys$UI$Control$get_visible() {
        /// <value type="Boolean" locid="P:J#Sys.UI.Control.visible"></value>
        if (arguments.length !== 0) throw Error.parameterCount();
        if (!this._element) throw Error.invalidOperation(Sys.Res.cantBeCalledAfterDispose);
        return Sys.UI.DomElement.getVisible(this._element);
    }
    function Sys$UI$Control$set_visible(value) {
        var e = Function._validateParams(arguments, [{name: "value", type: Boolean}]);
        if (e) throw e;
        if (!this._element) throw Error.invalidOperation(Sys.Res.cantBeCalledAfterDispose);
        Sys.UI.DomElement.setVisible(this._element, value)
    }
    function Sys$UI$Control$addCssClass(className) {
        /// <summary locid="M:J#Sys.UI.Control.addCssClass" />
        /// <param name="className" type="String"></param>
        var e = Function._validateParams(arguments, [
            {name: "className", type: String}
        ]);
        if (e) throw e;
        if (!this._element) throw Error.invalidOperation(Sys.Res.cantBeCalledAfterDispose);
        Sys.UI.DomElement.addCssClass(this._element, className);
    }
    function Sys$UI$Control$dispose() {
        Sys.UI.Control.callBaseMethod(this, 'dispose');
        if (this._element) {
            this._element.control = null;
            delete this._element;
        }
        if (this._parent) delete this._parent;
    }
    function Sys$UI$Control$onBubbleEvent(source, args) {
        /// <summary locid="M:J#Sys.UI.Control.onBubbleEvent" />
        /// <param name="source"></param>
        /// <param name="args" type="Sys.EventArgs"></param>
        /// <returns type="Boolean"></returns>
        var e = Function._validateParams(arguments, [
            {name: "source"},
            {name: "args", type: Sys.EventArgs}
        ]);
        if (e) throw e;
        return false;
    }
    function Sys$UI$Control$raiseBubbleEvent(source, args) {
        /// <summary locid="M:J#Sys.UI.Control.raiseBubbleEvent" />
        /// <param name="source"></param>
        /// <param name="args" type="Sys.EventArgs"></param>
        var e = Function._validateParams(arguments, [
            {name: "source"},
            {name: "args", type: Sys.EventArgs}
        ]);
        if (e) throw e;
        this._raiseBubbleEvent(source, args);
    }
    function Sys$UI$Control$_raiseBubbleEvent(source, args) {
        var currentTarget = this.get_parent();
        while (currentTarget) {
            if (currentTarget.onBubbleEvent(source, args)) {
                return;
            }
            currentTarget = currentTarget.get_parent();
        }
    }
    function Sys$UI$Control$removeCssClass(className) {
        /// <summary locid="M:J#Sys.UI.Control.removeCssClass" />
        /// <param name="className" type="String"></param>
        var e = Function._validateParams(arguments, [
            {name: "className", type: String}
        ]);
        if (e) throw e;
        if (!this._element) throw Error.invalidOperation(Sys.Res.cantBeCalledAfterDispose);
        Sys.UI.DomElement.removeCssClass(this._element, className);
    }
    function Sys$UI$Control$toggleCssClass(className) {
        /// <summary locid="M:J#Sys.UI.Control.toggleCssClass" />
        /// <param name="className" type="String"></param>
        var e = Function._validateParams(arguments, [
            {name: "className", type: String}
        ]);
        if (e) throw e;
        if (!this._element) throw Error.invalidOperation(Sys.Res.cantBeCalledAfterDispose);
        Sys.UI.DomElement.toggleCssClass(this._element, className);
    }
Sys.UI.Control.prototype = {
    _parent: null,
    _visibilityMode: Sys.UI.VisibilityMode.hide,
    get_element: Sys$UI$Control$get_element,
    get_id: Sys$UI$Control$get_id,
    set_id: Sys$UI$Control$set_id,
    get_parent: Sys$UI$Control$get_parent,
    set_parent: Sys$UI$Control$set_parent,
    get_role: Sys$UI$Control$get_role,
    get_visibilityMode: Sys$UI$Control$get_visibilityMode,
    set_visibilityMode: Sys$UI$Control$set_visibilityMode,
    get_visible: Sys$UI$Control$get_visible,
    set_visible: Sys$UI$Control$set_visible,
    addCssClass: Sys$UI$Control$addCssClass,
    dispose: Sys$UI$Control$dispose,
    onBubbleEvent: Sys$UI$Control$onBubbleEvent,
    raiseBubbleEvent: Sys$UI$Control$raiseBubbleEvent,
    _raiseBubbleEvent: Sys$UI$Control$_raiseBubbleEvent,
    removeCssClass: Sys$UI$Control$removeCssClass,
    toggleCssClass: Sys$UI$Control$toggleCssClass
}
Sys.UI.Control.registerClass('Sys.UI.Control', Sys.Component);
Sys.HistoryEventArgs = function Sys$HistoryEventArgs(state) {
    /// <summary locid="M:J#Sys.HistoryEventArgs.#ctor" />
    /// <param name="state" type="Object"></param>
    var e = Function._validateParams(arguments, [
        {name: "state", type: Object}
    ]);
    if (e) throw e;
    Sys.HistoryEventArgs.initializeBase(this);
    this._state = state;
}
    function Sys$HistoryEventArgs$get_state() {
        /// <value type="Object" locid="P:J#Sys.HistoryEventArgs.state"></value>
        if (arguments.length !== 0) throw Error.parameterCount();
        return this._state;
    }
Sys.HistoryEventArgs.prototype = {
    get_state: Sys$HistoryEventArgs$get_state
}
Sys.HistoryEventArgs.registerClass('Sys.HistoryEventArgs', Sys.EventArgs);
Sys.Application._appLoadHandler = null;
Sys.Application._beginRequestHandler = null;
Sys.Application._clientId = null;
Sys.Application._currentEntry = '';
Sys.Application._endRequestHandler = null;
Sys.Application._history = null;
Sys.Application._enableHistory = false;
Sys.Application._historyEnabledInScriptManager = false;
Sys.Application._historyFrame = null;
Sys.Application._historyInitialized = false;
Sys.Application._historyPointIsNew = false;
Sys.Application._ignoreTimer = false;
Sys.Application._initialState = null;
Sys.Application._state = {};
Sys.Application._timerCookie = 0;
Sys.Application._timerHandler = null;
Sys.Application._uniqueId = null;
Sys._Application.prototype.get_stateString = function Sys$_Application$get_stateString() {
    /// <summary locid="M:J#Sys._Application.get_stateString" />
    if (arguments.length !== 0) throw Error.parameterCount();
    var hash = null;
    
    if (Sys.Browser.agent === Sys.Browser.Firefox) {
        var href = window.location.href;
        var hashIndex = href.indexOf('#');
        if (hashIndex !== -1) {
            hash = href.substring(hashIndex + 1);
        }
        else {
            hash = "";
        }
        return hash;
    }
    else {
        hash = window.location.hash;
    }
    
    if ((hash.length > 0) && (hash.charAt(0) === '#')) {
        hash = hash.substring(1);
    }
    return hash;
};
Sys._Application.prototype.get_enableHistory = function Sys$_Application$get_enableHistory() {
    /// <summary locid="M:J#Sys._Application.get_enableHistory" />
    if (arguments.length !== 0) throw Error.parameterCount();
    return this._enableHistory;
};
Sys._Application.prototype.set_enableHistory = function Sys$_Application$set_enableHistory(value) {
    if (this._initialized && !this._initializing) {
        throw Error.invalidOperation(Sys.Res.historyCannotEnableHistory);
    }
    else if (this._historyEnabledInScriptManager && !value) {
        throw Error.invalidOperation(Sys.Res.invalidHistorySettingCombination);
    }
    this._enableHistory = value;
};
Sys._Application.prototype.add_navigate = function Sys$_Application$add_navigate(handler) {
    /// <summary locid="E:J#Sys.Application.navigate" />
    /// <param name="handler" type="Function"></param>
    var e = Function._validateParams(arguments, [
        {name: "handler", type: Function}
    ]);
    if (e) throw e;
    this.get_events().addHandler("navigate", handler);
};
Sys._Application.prototype.remove_navigate = function Sys$_Application$remove_navigate(handler) {
    /// <summary locid="M:J#Sys._Application.remove_navigate" />
    /// <param name="handler" type="Function"></param>
    var e = Function._validateParams(arguments, [
        {name: "handler", type: Function}
    ]);
    if (e) throw e;
    this.get_events().removeHandler("navigate", handler);
};
Sys._Application.prototype.addHistoryPoint = function Sys$_Application$addHistoryPoint(state, title) {
    /// <summary locid="M:J#Sys.Application.addHistoryPoint" />
    /// <param name="state" type="Object"></param>
    /// <param name="title" type="String" optional="true" mayBeNull="true"></param>
    var e = Function._validateParams(arguments, [
        {name: "state", type: Object},
        {name: "title", type: String, mayBeNull: true, optional: true}
    ]);
    if (e) throw e;
    if (!this._enableHistory) throw Error.invalidOperation(Sys.Res.historyCannotAddHistoryPointWithHistoryDisabled);
    for (var n in state) {
        var v = state[n];
        var t = typeof(v);
        if ((v !== null) && ((t === 'object') || (t === 'function') || (t === 'undefined'))) {
            throw Error.argument('state', Sys.Res.stateMustBeStringDictionary);
        }
    }
    this._ensureHistory();
    var initialState = this._state;
    for (var key in state) {
        var value = state[key];
        if (value === null) {
            if (typeof(initialState[key]) !== 'undefined') {
                delete initialState[key];
            }
        }
        else {
            initialState[key] = value;
        }
    }
    var entry = this._serializeState(initialState);
    this._historyPointIsNew = true;
    this._setState(entry, title);
    this._raiseNavigate();
};
Sys._Application.prototype.setServerId = function Sys$_Application$setServerId(clientId, uniqueId) {
    /// <summary locid="M:J#Sys.Application.setServerId" />
    /// <param name="clientId" type="String"></param>
    /// <param name="uniqueId" type="String"></param>
    var e = Function._validateParams(arguments, [
        {name: "clientId", type: String},
        {name: "uniqueId", type: String}
    ]);
    if (e) throw e;
    this._clientId = clientId;
    this._uniqueId = uniqueId;
};
Sys._Application.prototype.setServerState = function Sys$_Application$setServerState(value) {
    /// <summary locid="M:J#Sys.Application.setServerState" />
    /// <param name="value" type="String"></param>
    var e = Function._validateParams(arguments, [
        {name: "value", type: String}
    ]);
    if (e) throw e;
    this._ensureHistory();
    this._state.__s = value;
    this._updateHiddenField(value);
};
Sys._Application.prototype._deserializeState = function Sys$_Application$_deserializeState(entry) {
    var result = {};
    entry = entry || '';
    var serverSeparator = entry.indexOf('&&');
    if ((serverSeparator !== -1) && (serverSeparator + 2 < entry.length)) {
        result.__s = entry.substr(serverSeparator + 2);
        entry = entry.substr(0, serverSeparator);
    }
    var tokens = entry.split('&');
    for (var i = 0, l = tokens.length; i < l; i++) {
        var token = tokens[i];
        var equal = token.indexOf('=');
        if ((equal !== -1) && (equal + 1 < token.length)) {
            var name = token.substr(0, equal);
            var value = token.substr(equal + 1);
            result[name] = decodeURIComponent(value);
        }
    }
    return result;
};
Sys._Application.prototype._enableHistoryInScriptManager = function Sys$_Application$_enableHistoryInScriptManager() {
    this._enableHistory = true;
    this._historyEnabledInScriptManager = true;
};
Sys._Application.prototype._ensureHistory = function Sys$_Application$_ensureHistory() {
    if (!this._historyInitialized && this._enableHistory) {
        if ((Sys.Browser.agent === Sys.Browser.InternetExplorer) && 
            ((!document.documentMode) || document.documentMode < 8)) {
            this._historyFrame = document.getElementById('__historyFrame');
            if (!this._historyFrame) throw Error.invalidOperation(Sys.Res.historyMissingFrame);
            this._ignoreIFrame = true;
        }
        this._timerHandler = Function.createDelegate(this, this._onIdle);
        this._timerCookie = window.setTimeout(this._timerHandler, 100);
        
        try {
            this._initialState = this._deserializeState(this.get_stateString());
        } catch(e) {}
        
        this._historyInitialized = true;
    }
};
Sys._Application.prototype._navigate = function Sys$_Application$_navigate(entry) {
    this._ensureHistory();
    var state = this._deserializeState(entry);
    
    if (this._uniqueId) {
        var oldServerEntry = this._state.__s || '';
        var newServerEntry = state.__s || '';
        if (newServerEntry !== oldServerEntry) {
            this._updateHiddenField(newServerEntry);
            __doPostBack(this._uniqueId, newServerEntry);
            this._state = state;
            return;
        }
    }
    this._setState(entry);
    this._state = state;
    this._raiseNavigate();
};
Sys._Application.prototype._onIdle = function Sys$_Application$_onIdle() {
    delete this._timerCookie;
    
    var entry = this.get_stateString();
    if (entry !== this._currentEntry) {
        if (!this._ignoreTimer) {
            this._historyPointIsNew = false;
            this._navigate(entry);
        }
    }
    else {
        this._ignoreTimer = false;
    }
    this._timerCookie = window.setTimeout(this._timerHandler, 100);
};
Sys._Application.prototype._onIFrameLoad = function Sys$_Application$_onIFrameLoad(entry) {
    if ((!document.documentMode) || document.documentMode < 8 ) {
        this._ensureHistory();
        if (!this._ignoreIFrame) {
            this._historyPointIsNew = false;
            this._navigate(entry);
        }
        this._ignoreIFrame = false;
    }
};
Sys._Application.prototype._onPageRequestManagerBeginRequest = function Sys$_Application$_onPageRequestManagerBeginRequest(sender, args) {
    this._ignoreTimer = true;
    this._originalTitle = document.title;
};
Sys._Application.prototype._onPageRequestManagerEndRequest = function Sys$_Application$_onPageRequestManagerEndRequest(sender, args) {
    var dataItem = args.get_dataItems()[this._clientId];
    var originalTitle = this._originalTitle;
    this._originalTitle = null;
    var eventTarget = document.getElementById("__EVENTTARGET");
    if (eventTarget && eventTarget.value === this._uniqueId) {
        eventTarget.value = '';
    }
    if (typeof(dataItem) !== 'undefined') {
        this.setServerState(dataItem);
        this._historyPointIsNew = true;
    }
    else {
        this._ignoreTimer = false;
    }
    var entry = this._serializeState(this._state);
    if (entry !== this._currentEntry) {
        this._ignoreTimer = true;
        if (typeof(originalTitle) === "string") {
            if (Sys.Browser.agent !== Sys.Browser.InternetExplorer || Sys.Browser.version > 7) {
                var newTitle = document.title;
                document.title = originalTitle;
                this._setState(entry);
                document.title = newTitle;
            }
            else {
                this._setState(entry);
            }
            this._raiseNavigate();
        }
        else {
            this._setState(entry);
            this._raiseNavigate();
        }
    }
};
Sys._Application.prototype._raiseNavigate = function Sys$_Application$_raiseNavigate() {
    var isNew = this._historyPointIsNew;
    var h = this.get_events().getHandler("navigate");
    var stateClone = {};
    for (var key in this._state) {
        if (key !== '__s') {
            stateClone[key] = this._state[key];
        }
    }
    var args = new Sys.HistoryEventArgs(stateClone);
    if (h) {
        h(this, args);
    }
    if (!isNew) {
        var err;
        try {
            if ((Sys.Browser.agent === Sys.Browser.Firefox) && window.location.hash &&
                (!window.frameElement || window.top.location.hash)) {
                (Sys.Browser.version < 3.5) ?
                    window.history.go(0) :
                    location.hash = this.get_stateString();
            }
        }
        catch(err) {
        }
    }
};
Sys._Application.prototype._serializeState = function Sys$_Application$_serializeState(state) {
    var serialized = [];
    for (var key in state) {
        var value = state[key];
        if (key === '__s') {
            var serverState = value;
        }
        else {
            if (key.indexOf('=') !== -1) throw Error.argument('state', Sys.Res.stateFieldNameInvalid);
            serialized[serialized.length] = key + '=' + encodeURIComponent(value);
        }
    }
    return serialized.join('&') + (serverState ? '&&' + serverState : '');
};
Sys._Application.prototype._setState = function Sys$_Application$_setState(entry, title) {
    if (this._enableHistory) {
        entry = entry || '';
        if (entry !== this._currentEntry) {
            if (window.theForm) {
                var action = window.theForm.action;
                var hashIndex = action.indexOf('#');
                window.theForm.action = ((hashIndex !== -1) ? action.substring(0, hashIndex) : action) + '#' + entry;
            }
        
            if (this._historyFrame && this._historyPointIsNew) {
                var newDiv = document.createElement("div");
                newDiv.appendChild(document.createTextNode(title || document.title));
                var htmlEncodedTitle = newDiv.innerHTML;
                this._ignoreIFrame = true;
                var frameDoc = this._historyFrame.contentWindow.document;
                frameDoc.open("javascript:'<html></html>'");
                frameDoc.write("<html><head><title>" + htmlEncodedTitle +
                    "</title><scri" + "pt type=\"text/javascript\">parent.Sys.Application._onIFrameLoad(" + 
                    Sys.Serialization.JavaScriptSerializer.serialize(entry) +
                    ");</scri" + "pt></head><body></body></html>");
                frameDoc.close();
            }
            this._ignoreTimer = false;
            this._currentEntry = entry;
            if (this._historyFrame || this._historyPointIsNew) {
                var currentHash = this.get_stateString();
                if (entry !== currentHash) {
                    var loc = document.location;
                    if (loc.href.length - loc.hash.length + entry.length > 2048) {
                        throw Error.invalidOperation(String.format(Sys.Res.urlTooLong, 2048));
                    }
                    window.location.hash = entry;
                    this._currentEntry = this.get_stateString();
                    if ((typeof(title) !== 'undefined') && (title !== null)) {
                        document.title = title;
                    }
                }
            }
            this._historyPointIsNew = false;
        }
    }
};
Sys._Application.prototype._updateHiddenField = function Sys$_Application$_updateHiddenField(value) {
    if (this._clientId) {
        var serverStateField = document.getElementById(this._clientId);
        if (serverStateField) {
            serverStateField.value = value;
        }
    }
};
 
if (!window.XMLHttpRequest) {
    window.XMLHttpRequest = function window$XMLHttpRequest() {
        var progIDs = [ 'Msxml2.XMLHTTP.3.0', 'Msxml2.XMLHTTP' ];
        for (var i = 0, l = progIDs.length; i < l; i++) {
            try {
                return new ActiveXObject(progIDs[i]);
            }
            catch (ex) {
            }
        }
        return null;
    }
}
Type.registerNamespace('Sys.Net');
 
Sys.Net.WebRequestExecutor = function Sys$Net$WebRequestExecutor() {
    /// <summary locid="M:J#Sys.Net.WebRequestExecutor.#ctor" />
    if (arguments.length !== 0) throw Error.parameterCount();
    this._webRequest = null;
    this._resultObject = null;
}
    function Sys$Net$WebRequestExecutor$get_webRequest() {
        /// <value type="Sys.Net.WebRequest" locid="P:J#Sys.Net.WebRequestExecutor.webRequest"></value>
        if (arguments.length !== 0) throw Error.parameterCount();
        return this._webRequest;
    }
    function Sys$Net$WebRequestExecutor$_set_webRequest(value) {
        if (this.get_started()) {
            throw Error.invalidOperation(String.format(Sys.Res.cannotCallOnceStarted, 'set_webRequest'));
        }
        this._webRequest = value;
    }
    function Sys$Net$WebRequestExecutor$get_started() {
        /// <value type="Boolean" locid="P:J#Sys.Net.WebRequestExecutor.started"></value>
        if (arguments.length !== 0) throw Error.parameterCount();
        throw Error.notImplemented();
    }
    function Sys$Net$WebRequestExecutor$get_responseAvailable() {
        /// <value type="Boolean" locid="P:J#Sys.Net.WebRequestExecutor.responseAvailable"></value>
        if (arguments.length !== 0) throw Error.parameterCount();
        throw Error.notImplemented();
    }
    function Sys$Net$WebRequestExecutor$get_timedOut() {
        /// <value type="Boolean" locid="P:J#Sys.Net.WebRequestExecutor.timedOut"></value>
        if (arguments.length !== 0) throw Error.parameterCount();
        throw Error.notImplemented();
    }
    function Sys$Net$WebRequestExecutor$get_aborted() {
        /// <value type="Boolean" locid="P:J#Sys.Net.WebRequestExecutor.aborted"></value>
        if (arguments.length !== 0) throw Error.parameterCount();
        throw Error.notImplemented();
    }
    function Sys$Net$WebRequestExecutor$get_responseData() {
        /// <value type="String" locid="P:J#Sys.Net.WebRequestExecutor.responseData"></value>
        if (arguments.length !== 0) throw Error.parameterCount();
        throw Error.notImplemented();
    }
    function Sys$Net$WebRequestExecutor$get_statusCode() {
        /// <value type="Number" locid="P:J#Sys.Net.WebRequestExecutor.statusCode"></value>
        if (arguments.length !== 0) throw Error.parameterCount();
        throw Error.notImplemented();
    }
    function Sys$Net$WebRequestExecutor$get_statusText() {
        /// <value type="String" locid="P:J#Sys.Net.WebRequestExecutor.statusText"></value>
        if (arguments.length !== 0) throw Error.parameterCount();
        throw Error.notImplemented();
    }
    function Sys$Net$WebRequestExecutor$get_xml() {
        /// <value locid="P:J#Sys.Net.WebRequestExecutor.xml"></value>
        if (arguments.length !== 0) throw Error.parameterCount();
        throw Error.notImplemented();
    }
    function Sys$Net$WebRequestExecutor$get_object() {
        /// <value locid="P:J#Sys.Net.WebRequestExecutor.object"></value>
        if (arguments.length !== 0) throw Error.parameterCount();
        if (!this._resultObject) {
            this._resultObject = Sys.Serialization.JavaScriptSerializer.deserialize(this.get_responseData());
        }
        return this._resultObject;
    }
    function Sys$Net$WebRequestExecutor$executeRequest() {
        /// <summary locid="M:J#Sys.Net.WebRequestExecutor.executeRequest" />
        if (arguments.length !== 0) throw Error.parameterCount();
        throw Error.notImplemented();
    }
    function Sys$Net$WebRequestExecutor$abort() {
        /// <summary locid="M:J#Sys.Net.WebRequestExecutor.abort" />
        if (arguments.length !== 0) throw Error.parameterCount();
        throw Error.notImplemented();
    }
    function Sys$Net$WebRequestExecutor$getResponseHeader(header) {
        /// <summary locid="M:J#Sys.Net.WebRequestExecutor.getResponseHeader" />
        /// <param name="header" type="String"></param>
        var e = Function._validateParams(arguments, [
            {name: "header", type: String}
        ]);
        if (e) throw e;
        throw Error.notImplemented();
    }
    function Sys$Net$WebRequestExecutor$getAllResponseHeaders() {
        /// <summary locid="M:J#Sys.Net.WebRequestExecutor.getAllResponseHeaders" />
        if (arguments.length !== 0) throw Error.parameterCount();
        throw Error.notImplemented();
    }
Sys.Net.WebRequestExecutor.prototype = {
    get_webRequest: Sys$Net$WebRequestExecutor$get_webRequest,
    _set_webRequest: Sys$Net$WebRequestExecutor$_set_webRequest,
    get_started: Sys$Net$WebRequestExecutor$get_started,
    get_responseAvailable: Sys$Net$WebRequestExecutor$get_responseAvailable,
    get_timedOut: Sys$Net$WebRequestExecutor$get_timedOut,
    get_aborted: Sys$Net$WebRequestExecutor$get_aborted,
    get_responseData: Sys$Net$WebRequestExecutor$get_responseData,
    get_statusCode: Sys$Net$WebRequestExecutor$get_statusCode,
    get_statusText: Sys$Net$WebRequestExecutor$get_statusText,
    get_xml: Sys$Net$WebRequestExecutor$get_xml,
    get_object: Sys$Net$WebRequestExecutor$get_object,
    executeRequest: Sys$Net$WebRequestExecutor$executeRequest,
    abort: Sys$Net$WebRequestExecutor$abort,
    getResponseHeader: Sys$Net$WebRequestExecutor$getResponseHeader,
    getAllResponseHeaders: Sys$Net$WebRequestExecutor$getAllResponseHeaders
}
Sys.Net.WebRequestExecutor.registerClass('Sys.Net.WebRequestExecutor');
 
Sys.Net.XMLDOM = function Sys$Net$XMLDOM(markup) {
    /// <summary locid="M:J#Sys.Net.XMLDOM.#ctor" />
    /// <param name="markup" type="String"></param>
    var e = Function._validateParams(arguments, [
        {name: "markup", type: String}
    ]);
    if (e) throw e;
    if (!window.DOMParser) {
        var progIDs = [ 'Msxml2.DOMDocument.3.0', 'Msxml2.DOMDocument' ];
        for (var i = 0, l = progIDs.length; i < l; i++) {
            try {
                var xmlDOM = new ActiveXObject(progIDs[i]);
                xmlDOM.async = false;
                xmlDOM.loadXML(markup);
                xmlDOM.setProperty('SelectionLanguage', 'XPath');
                return xmlDOM;
            }
            catch (ex) {
            }
        }
    }
    else {
        try {
            var domParser = new window.DOMParser();
            return domParser.parseFromString(markup, 'text/xml');
        }
        catch (ex) {
        }
    }
    return null;
}
Sys.Net.XMLHttpExecutor = function Sys$Net$XMLHttpExecutor() {
    /// <summary locid="M:J#Sys.Net.XMLHttpExecutor.#ctor" />
    if (arguments.length !== 0) throw Error.parameterCount();
    Sys.Net.XMLHttpExecutor.initializeBase(this);
    var _this = this;
    this._xmlHttpRequest = null;
    this._webRequest = null;
    this._responseAvailable = false;
    this._timedOut = false;
    this._timer = null;
    this._aborted = false;
    this._started = false;
    this._onReadyStateChange = (function () {
        
        if (_this._xmlHttpRequest.readyState === 4 ) {
            try {
                if (typeof(_this._xmlHttpRequest.status) === "undefined" || _this._xmlHttpRequest.status === 0) {
                    return;
                }
            }
            catch(ex) {
                return;
            }
            
            _this._clearTimer();
            _this._responseAvailable = true;
                _this._webRequest.completed(Sys.EventArgs.Empty);
                if (_this._xmlHttpRequest != null) {
                    _this._xmlHttpRequest.onreadystatechange = Function.emptyMethod;
                    _this._xmlHttpRequest = null;
                }
        }
    });
    this._clearTimer = (function() {
        if (_this._timer != null) {
            window.clearTimeout(_this._timer);
            _this._timer = null;
        }
    });
    this._onTimeout = (function() {
        if (!_this._responseAvailable) {
            _this._clearTimer();
            _this._timedOut = true;
            _this._xmlHttpRequest.onreadystatechange = Function.emptyMethod;
            _this._xmlHttpRequest.abort();
            _this._webRequest.completed(Sys.EventArgs.Empty);
            _this._xmlHttpRequest = null;
        }
    });
}
    function Sys$Net$XMLHttpExecutor$get_timedOut() {
        /// <value type="Boolean" locid="P:J#Sys.Net.XMLHttpExecutor.timedOut"></value>
        if (arguments.length !== 0) throw Error.parameterCount();
        return this._timedOut;
    }
    function Sys$Net$XMLHttpExecutor$get_started() {
        /// <value type="Boolean" locid="P:J#Sys.Net.XMLHttpExecutor.started"></value>
        if (arguments.length !== 0) throw Error.parameterCount();
        return this._started;
    }
    function Sys$Net$XMLHttpExecutor$get_responseAvailable() {
        /// <value type="Boolean" locid="P:J#Sys.Net.XMLHttpExecutor.responseAvailable"></value>
        if (arguments.length !== 0) throw Error.parameterCount();
        return this._responseAvailable;
    }
    function Sys$Net$XMLHttpExecutor$get_aborted() {
        /// <value type="Boolean" locid="P:J#Sys.Net.XMLHttpExecutor.aborted"></value>
        if (arguments.length !== 0) throw Error.parameterCount();
        return this._aborted;
    }
    function Sys$Net$XMLHttpExecutor$executeRequest() {
        /// <summary locid="M:J#Sys.Net.XMLHttpExecutor.executeRequest" />
        if (arguments.length !== 0) throw Error.parameterCount();
        this._webRequest = this.get_webRequest();
        if (this._started) {
            throw Error.invalidOperation(String.format(Sys.Res.cannotCallOnceStarted, 'executeRequest'));
        }
        if (this._webRequest === null) {
            throw Error.invalidOperation(Sys.Res.nullWebRequest);
        }
        var body = this._webRequest.get_body();
        var headers = this._webRequest.get_headers();
        this._xmlHttpRequest = new XMLHttpRequest();
        this._xmlHttpRequest.onreadystatechange = this._onReadyStateChange;
        var verb = this._webRequest.get_httpVerb();
        this._xmlHttpRequest.open(verb, this._webRequest.getResolvedUrl(), true );
        this._xmlHttpRequest.setRequestHeader("X-Requested-With", "XMLHttpRequest");
        if (headers) {
            for (var header in headers) {
                var val = headers[header];
                if (typeof(val) !== "function")
                    this._xmlHttpRequest.setRequestHeader(header, val);
            }
        }
        if (verb.toLowerCase() === "post") {
            if ((headers === null) || !headers['Content-Type']) {
                this._xmlHttpRequest.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded; charset=utf-8');
            }
            if (!body) {
                body = "";
            }
        }
        var timeout = this._webRequest.get_timeout();
        if (timeout > 0) {
            this._timer = window.setTimeout(Function.createDelegate(this, this._onTimeout), timeout);
        }
        this._xmlHttpRequest.send(body);
        this._started = true;
    }
    function Sys$Net$XMLHttpExecutor$getResponseHeader(header) {
        /// <summary locid="M:J#Sys.Net.XMLHttpExecutor.getResponseHeader" />
        /// <param name="header" type="String"></param>
        /// <returns type="String"></returns>
        var e = Function._validateParams(arguments, [
            {name: "header", type: String}
        ]);
        if (e) throw e;
        if (!this._responseAvailable) {
            throw Error.invalidOperation(String.format(Sys.Res.cannotCallBeforeResponse, 'getResponseHeader'));
        }
        if (!this._xmlHttpRequest) {
            throw Error.invalidOperation(String.format(Sys.Res.cannotCallOutsideHandler, 'getResponseHeader'));
        }
        var result;
        try {
            result = this._xmlHttpRequest.getResponseHeader(header);
        } catch (e) {
        }
        if (!result) result = "";
        return result;
    }
    function Sys$Net$XMLHttpExecutor$getAllResponseHeaders() {
        /// <summary locid="M:J#Sys.Net.XMLHttpExecutor.getAllResponseHeaders" />
        /// <returns type="String"></returns>
        if (arguments.length !== 0) throw Error.parameterCount();
        if (!this._responseAvailable) {
            throw Error.invalidOperation(String.format(Sys.Res.cannotCallBeforeResponse, 'getAllResponseHeaders'));
        }
        if (!this._xmlHttpRequest) {
            throw Error.invalidOperation(String.format(Sys.Res.cannotCallOutsideHandler, 'getAllResponseHeaders'));
        }
        return this._xmlHttpRequest.getAllResponseHeaders();
    }
    function Sys$Net$XMLHttpExecutor$get_responseData() {
        /// <value type="String" locid="P:J#Sys.Net.XMLHttpExecutor.responseData"></value>
        if (arguments.length !== 0) throw Error.parameterCount();
        if (!this._responseAvailable) {
            throw Error.invalidOperation(String.format(Sys.Res.cannotCallBeforeResponse, 'get_responseData'));
        }
        if (!this._xmlHttpRequest) {
            throw Error.invalidOperation(String.format(Sys.Res.cannotCallOutsideHandler, 'get_responseData'));
        }
        return this._xmlHttpRequest.responseText;
    }
    function Sys$Net$XMLHttpExecutor$get_statusCode() {
        /// <value type="Number" locid="P:J#Sys.Net.XMLHttpExecutor.statusCode"></value>
        if (arguments.length !== 0) throw Error.parameterCount();
        if (!this._responseAvailable) {
            throw Error.invalidOperation(String.format(Sys.Res.cannotCallBeforeResponse, 'get_statusCode'));
        }
        if (!this._xmlHttpRequest) {
            throw Error.invalidOperation(String.format(Sys.Res.cannotCallOutsideHandler, 'get_statusCode'));
        }
        var result = 0;
        try {
            result = this._xmlHttpRequest.status;
        }
        catch(ex) {
        }
        return result;
    }
    function Sys$Net$XMLHttpExecutor$get_statusText() {
        /// <value type="String" locid="P:J#Sys.Net.XMLHttpExecutor.statusText"></value>
        if (arguments.length !== 0) throw Error.parameterCount();
        if (!this._responseAvailable) {
            throw Error.invalidOperation(String.format(Sys.Res.cannotCallBeforeResponse, 'get_statusText'));
        }
        if (!this._xmlHttpRequest) {
            throw Error.invalidOperation(String.format(Sys.Res.cannotCallOutsideHandler, 'get_statusText'));
        }
        return this._xmlHttpRequest.statusText;
    }
    function Sys$Net$XMLHttpExecutor$get_xml() {
        /// <value locid="P:J#Sys.Net.XMLHttpExecutor.xml"></value>
        if (arguments.length !== 0) throw Error.parameterCount();
        if (!this._responseAvailable) {
            throw Error.invalidOperation(String.format(Sys.Res.cannotCallBeforeResponse, 'get_xml'));
        }
        if (!this._xmlHttpRequest) {
            throw Error.invalidOperation(String.format(Sys.Res.cannotCallOutsideHandler, 'get_xml'));
        }
        var xml = this._xmlHttpRequest.responseXML;
        if (!xml || !xml.documentElement) {
            xml = Sys.Net.XMLDOM(this._xmlHttpRequest.responseText);
            if (!xml || !xml.documentElement)
                return null;
        }
        else if (navigator.userAgent.indexOf('MSIE') !== -1 && typeof(xml.setProperty) != 'undefined') {
            xml.setProperty('SelectionLanguage', 'XPath');
        }
        if (xml.documentElement.namespaceURI === "http://www.mozilla.org/newlayout/xml/parsererror.xml" &&
            xml.documentElement.tagName === "parsererror") {
            return null;
        }
        
        if (xml.documentElement.firstChild && xml.documentElement.firstChild.tagName === "parsererror") {
            return null;
        }
        
        return xml;
    }
    function Sys$Net$XMLHttpExecutor$abort() {
        /// <summary locid="M:J#Sys.Net.XMLHttpExecutor.abort" />
        if (arguments.length !== 0) throw Error.parameterCount();
        if (!this._started) {
            throw Error.invalidOperation(Sys.Res.cannotAbortBeforeStart);
        }
        if (this._aborted || this._responseAvailable || this._timedOut)
            return;
        this._aborted = true;
        this._clearTimer();
        if (this._xmlHttpRequest && !this._responseAvailable) {
            this._xmlHttpRequest.onreadystatechange = Function.emptyMethod;
            this._xmlHttpRequest.abort();
            
            this._xmlHttpRequest = null;            
            this._webRequest.completed(Sys.EventArgs.Empty);
        }
    }
Sys.Net.XMLHttpExecutor.prototype = {
    get_timedOut: Sys$Net$XMLHttpExecutor$get_timedOut,
    get_started: Sys$Net$XMLHttpExecutor$get_started,
    get_responseAvailable: Sys$Net$XMLHttpExecutor$get_responseAvailable,
    get_aborted: Sys$Net$XMLHttpExecutor$get_aborted,
    executeRequest: Sys$Net$XMLHttpExecutor$executeRequest,
    getResponseHeader: Sys$Net$XMLHttpExecutor$getResponseHeader,
    getAllResponseHeaders: Sys$Net$XMLHttpExecutor$getAllResponseHeaders,
    get_responseData: Sys$Net$XMLHttpExecutor$get_responseData,
    get_statusCode: Sys$Net$XMLHttpExecutor$get_statusCode,
    get_statusText: Sys$Net$XMLHttpExecutor$get_statusText,
    get_xml: Sys$Net$XMLHttpExecutor$get_xml,
    abort: Sys$Net$XMLHttpExecutor$abort
}
Sys.Net.XMLHttpExecutor.registerClass('Sys.Net.XMLHttpExecutor', Sys.Net.WebRequestExecutor);
 
Sys.Net._WebRequestManager = function Sys$Net$_WebRequestManager() {
    /// <summary locid="P:J#Sys.Net.WebRequestManager.#ctor" />
    if (arguments.length !== 0) throw Error.parameterCount();
    this._defaultTimeout = 0;
    this._defaultExecutorType = "Sys.Net.XMLHttpExecutor";
}
    function Sys$Net$_WebRequestManager$add_invokingRequest(handler) {
        /// <summary locid="E:J#Sys.Net.WebRequestManager.invokingRequest" />
        var e = Function._validateParams(arguments, [{name: "handler", type: Function}]);
        if (e) throw e;
        this._get_eventHandlerList().addHandler("invokingRequest", handler);
    }
    function Sys$Net$_WebRequestManager$remove_invokingRequest(handler) {
        var e = Function._validateParams(arguments, [{name: "handler", type: Function}]);
        if (e) throw e;
        this._get_eventHandlerList().removeHandler("invokingRequest", handler);
    }
    function Sys$Net$_WebRequestManager$add_completedRequest(handler) {
        /// <summary locid="E:J#Sys.Net.WebRequestManager.completedRequest" />
        var e = Function._validateParams(arguments, [{name: "handler", type: Function}]);
        if (e) throw e;
        this._get_eventHandlerList().addHandler("completedRequest", handler);
    }
    function Sys$Net$_WebRequestManager$remove_completedRequest(handler) {
        var e = Function._validateParams(arguments, [{name: "handler", type: Function}]);
        if (e) throw e;
        this._get_eventHandlerList().removeHandler("completedRequest", handler);
    }
    function Sys$Net$_WebRequestManager$_get_eventHandlerList() {
        if (!this._events) {
            this._events = new Sys.EventHandlerList();
        }
        return this._events;
    }
    function Sys$Net$_WebRequestManager$get_defaultTimeout() {
        /// <value type="Number" locid="P:J#Sys.Net.WebRequestManager.defaultTimeout"></value>
        if (arguments.length !== 0) throw Error.parameterCount();
        return this._defaultTimeout;
    }
    function Sys$Net$_WebRequestManager$set_defaultTimeout(value) {
        var e = Function._validateParams(arguments, [{name: "value", type: Number}]);
        if (e) throw e;
        if (value < 0) {
            throw Error.argumentOutOfRange("value", value, Sys.Res.invalidTimeout);
        }
        this._defaultTimeout = value;
    }
    function Sys$Net$_WebRequestManager$get_defaultExecutorType() {
        /// <value type="String" locid="P:J#Sys.Net.WebRequestManager.defaultExecutorType"></value>
        if (arguments.length !== 0) throw Error.parameterCount();
        return this._defaultExecutorType;
    }
    function Sys$Net$_WebRequestManager$set_defaultExecutorType(value) {
        var e = Function._validateParams(arguments, [{name: "value", type: String}]);
        if (e) throw e;
        this._defaultExecutorType = value;
    }
    function Sys$Net$_WebRequestManager$executeRequest(webRequest) {
        /// <summary locid="M:J#Sys.Net.WebRequestManager.executeRequest" />
        /// <param name="webRequest" type="Sys.Net.WebRequest"></param>
        var e = Function._validateParams(arguments, [
            {name: "webRequest", type: Sys.Net.WebRequest}
        ]);
        if (e) throw e;
        var executor = webRequest.get_executor();
        if (!executor) {
            var failed = false;
            try {
                var executorType = eval(this._defaultExecutorType);
                executor = new executorType();
            } catch (e) {
                failed = true;
            }
            if (failed  || !Sys.Net.WebRequestExecutor.isInstanceOfType(executor) || !executor) {
                throw Error.argument("defaultExecutorType", String.format(Sys.Res.invalidExecutorType, this._defaultExecutorType));
            }
            webRequest.set_executor(executor);
        }
        if (executor.get_aborted()) {
            return;
        }
        var evArgs = new Sys.Net.NetworkRequestEventArgs(webRequest);
        var handler = this._get_eventHandlerList().getHandler("invokingRequest");
        if (handler) {
            handler(this, evArgs);
        }
        if (!evArgs.get_cancel()) {
            executor.executeRequest();
        }
    }
Sys.Net._WebRequestManager.prototype = {
    add_invokingRequest: Sys$Net$_WebRequestManager$add_invokingRequest,
    remove_invokingRequest: Sys$Net$_WebRequestManager$remove_invokingRequest,
    add_completedRequest: Sys$Net$_WebRequestManager$add_completedRequest,
    remove_completedRequest: Sys$Net$_WebRequestManager$remove_completedRequest,
    _get_eventHandlerList: Sys$Net$_WebRequestManager$_get_eventHandlerList,
    get_defaultTimeout: Sys$Net$_WebRequestManager$get_defaultTimeout,
    set_defaultTimeout: Sys$Net$_WebRequestManager$set_defaultTimeout,
    get_defaultExecutorType: Sys$Net$_WebRequestManager$get_defaultExecutorType,
    set_defaultExecutorType: Sys$Net$_WebRequestManager$set_defaultExecutorType,
    executeRequest: Sys$Net$_WebRequestManager$executeRequest
}
Sys.Net._WebRequestManager.registerClass('Sys.Net._WebRequestManager');
Sys.Net.WebRequestManager = new Sys.Net._WebRequestManager();
 
Sys.Net.NetworkRequestEventArgs = function Sys$Net$NetworkRequestEventArgs(webRequest) {
    /// <summary locid="M:J#Sys.Net.NetworkRequestEventArgs.#ctor" />
    /// <param name="webRequest" type="Sys.Net.WebRequest"></param>
    var e = Function._validateParams(arguments, [
        {name: "webRequest", type: Sys.Net.WebRequest}
    ]);
    if (e) throw e;
    Sys.Net.NetworkRequestEventArgs.initializeBase(this);
    this._webRequest = webRequest;
}
    function Sys$Net$NetworkRequestEventArgs$get_webRequest() {
        /// <value type="Sys.Net.WebRequest" locid="P:J#Sys.Net.NetworkRequestEventArgs.webRequest"></value>
        if (arguments.length !== 0) throw Error.parameterCount();
        return this._webRequest;
    }
Sys.Net.NetworkRequestEventArgs.prototype = {
    get_webRequest: Sys$Net$NetworkRequestEventArgs$get_webRequest
}
Sys.Net.NetworkRequestEventArgs.registerClass('Sys.Net.NetworkRequestEventArgs', Sys.CancelEventArgs);
 
Sys.Net.WebRequest = function Sys$Net$WebRequest() {
    /// <summary locid="M:J#Sys.Net.WebRequest.#ctor" />
    if (arguments.length !== 0) throw Error.parameterCount();
    this._url = "";
    this._headers = { };
    this._body = null;
    this._userContext = null;
    this._httpVerb = null;
    this._executor = null;
    this._invokeCalled = false;
    this._timeout = 0;
}
    function Sys$Net$WebRequest$add_completed(handler) {
    /// <summary locid="E:J#Sys.Net.WebRequest.completed" />
    var e = Function._validateParams(arguments, [{name: "handler", type: Function}]);
    if (e) throw e;
        this._get_eventHandlerList().addHandler("completed", handler);
    }
    function Sys$Net$WebRequest$remove_completed(handler) {
    var e = Function._validateParams(arguments, [{name: "handler", type: Function}]);
    if (e) throw e;
        this._get_eventHandlerList().removeHandler("completed", handler);
    }
    function Sys$Net$WebRequest$completed(eventArgs) {
        /// <summary locid="M:J#Sys.Net.WebRequest.completed" />
        /// <param name="eventArgs" type="Sys.EventArgs"></param>
        var e = Function._validateParams(arguments, [
            {name: "eventArgs", type: Sys.EventArgs}
        ]);
        if (e) throw e;
        var handler = Sys.Net.WebRequestManager._get_eventHandlerList().getHandler("completedRequest");
        if (handler) {
            handler(this._executor, eventArgs);
        }
        handler = this._get_eventHandlerList().getHandler("completed");
        if (handler) {
            handler(this._executor, eventArgs);
        }
    }
    function Sys$Net$WebRequest$_get_eventHandlerList() {
        if (!this._events) {
            this._events = new Sys.EventHandlerList();
        }
        return this._events;
    }
    function Sys$Net$WebRequest$get_url() {
        /// <value type="String" locid="P:J#Sys.Net.WebRequest.url"></value>
        if (arguments.length !== 0) throw Error.parameterCount();
        return this._url;
    }
    function Sys$Net$WebRequest$set_url(value) {
        var e = Function._validateParams(arguments, [{name: "value", type: String}]);
        if (e) throw e;
        this._url = value;
    }
    function Sys$Net$WebRequest$get_headers() {
        /// <value locid="P:J#Sys.Net.WebRequest.headers"></value>
        if (arguments.length !== 0) throw Error.parameterCount();
        return this._headers;
    }
    function Sys$Net$WebRequest$get_httpVerb() {
        /// <value type="String" locid="P:J#Sys.Net.WebRequest.httpVerb"></value>
        if (arguments.length !== 0) throw Error.parameterCount();
        if (this._httpVerb === null) {
            if (this._body === null) {
                return "GET";
            }
            return "POST";
        }
        return this._httpVerb;
    }
    function Sys$Net$WebRequest$set_httpVerb(value) {
        var e = Function._validateParams(arguments, [{name: "value", type: String}]);
        if (e) throw e;
        if (value.length === 0) {
            throw Error.argument('value', Sys.Res.invalidHttpVerb);
        }
        this._httpVerb = value;
    }
    function Sys$Net$WebRequest$get_body() {
        /// <value mayBeNull="true" locid="P:J#Sys.Net.WebRequest.body"></value>
        if (arguments.length !== 0) throw Error.parameterCount();
        return this._body;
    }
    function Sys$Net$WebRequest$set_body(value) {
        var e = Function._validateParams(arguments, [{name: "value", mayBeNull: true}]);
        if (e) throw e;
        this._body = value;
    }
    function Sys$Net$WebRequest$get_userContext() {
        /// <value mayBeNull="true" locid="P:J#Sys.Net.WebRequest.userContext"></value>
        if (arguments.length !== 0) throw Error.parameterCount();
        return this._userContext;
    }
    function Sys$Net$WebRequest$set_userContext(value) {
        var e = Function._validateParams(arguments, [{name: "value", mayBeNull: true}]);
        if (e) throw e;
        this._userContext = value;
    }
    function Sys$Net$WebRequest$get_executor() {
        /// <value type="Sys.Net.WebRequestExecutor" locid="P:J#Sys.Net.WebRequest.executor"></value>
        if (arguments.length !== 0) throw Error.parameterCount();
        return this._executor;
    }
    function Sys$Net$WebRequest$set_executor(value) {
        var e = Function._validateParams(arguments, [{name: "value", type: Sys.Net.WebRequestExecutor}]);
        if (e) throw e;
        if (this._executor !== null && this._executor.get_started()) {
            throw Error.invalidOperation(Sys.Res.setExecutorAfterActive);
        }
        this._executor = value;
        this._executor._set_webRequest(this);
    }
    function Sys$Net$WebRequest$get_timeout() {
        /// <value type="Number" locid="P:J#Sys.Net.WebRequest.timeout"></value>
        if (arguments.length !== 0) throw Error.parameterCount();
        if (this._timeout === 0) {
            return Sys.Net.WebRequestManager.get_defaultTimeout();
        }
        return this._timeout;
    }
    function Sys$Net$WebRequest$set_timeout(value) {
        var e = Function._validateParams(arguments, [{name: "value", type: Number}]);
        if (e) throw e;
        if (value < 0) {
            throw Error.argumentOutOfRange("value", value, Sys.Res.invalidTimeout);
        }
        this._timeout = value;
    }
    function Sys$Net$WebRequest$getResolvedUrl() {
        /// <summary locid="M:J#Sys.Net.WebRequest.getResolvedUrl" />
        /// <returns type="String"></returns>
        if (arguments.length !== 0) throw Error.parameterCount();
        return Sys.Net.WebRequest._resolveUrl(this._url);
    }
    function Sys$Net$WebRequest$invoke() {
        /// <summary locid="M:J#Sys.Net.WebRequest.invoke" />
        if (arguments.length !== 0) throw Error.parameterCount();
        if (this._invokeCalled) {
            throw Error.invalidOperation(Sys.Res.invokeCalledTwice);
        }
        Sys.Net.WebRequestManager.executeRequest(this);
        this._invokeCalled = true;
    }
Sys.Net.WebRequest.prototype = {
    add_completed: Sys$Net$WebRequest$add_completed,
    remove_completed: Sys$Net$WebRequest$remove_completed,
    completed: Sys$Net$WebRequest$completed,
    _get_eventHandlerList: Sys$Net$WebRequest$_get_eventHandlerList,
    get_url: Sys$Net$WebRequest$get_url,
    set_url: Sys$Net$WebRequest$set_url,
    get_headers: Sys$Net$WebRequest$get_headers,
    get_httpVerb: Sys$Net$WebRequest$get_httpVerb,
    set_httpVerb: Sys$Net$WebRequest$set_httpVerb,
    get_body: Sys$Net$WebRequest$get_body,
    set_body: Sys$Net$WebRequest$set_body,
    get_userContext: Sys$Net$WebRequest$get_userContext,
    set_userContext: Sys$Net$WebRequest$set_userContext,
    get_executor: Sys$Net$WebRequest$get_executor,
    set_executor: Sys$Net$WebRequest$set_executor,
    get_timeout: Sys$Net$WebRequest$get_timeout,
    set_timeout: Sys$Net$WebRequest$set_timeout,
    getResolvedUrl: Sys$Net$WebRequest$getResolvedUrl,
    invoke: Sys$Net$WebRequest$invoke
}
Sys.Net.WebRequest._resolveUrl = function Sys$Net$WebRequest$_resolveUrl(url, baseUrl) {
    if (url && url.indexOf('://') !== -1) {
        return url;
    }
    if (!baseUrl || baseUrl.length === 0) {
        var baseElement = document.getElementsByTagName('base')[0];
        if (baseElement && baseElement.href && baseElement.href.length > 0) {
            baseUrl = baseElement.href;
        }
        else {
            baseUrl = document.URL;
        }
    }
    var qsStart = baseUrl.indexOf('?');
    if (qsStart !== -1) {
        baseUrl = baseUrl.substr(0, qsStart);
    }
    qsStart = baseUrl.indexOf('#');
    if (qsStart !== -1) {
        baseUrl = baseUrl.substr(0, qsStart);
    }
    baseUrl = baseUrl.substr(0, baseUrl.lastIndexOf('/') + 1);
    if (!url || url.length === 0) {
        return baseUrl;
    }
    if (url.charAt(0) === '/') {
        var slashslash = baseUrl.indexOf('://');
        if (slashslash === -1) {
            throw Error.argument("baseUrl", Sys.Res.badBaseUrl1);
        }
        var nextSlash = baseUrl.indexOf('/', slashslash + 3);
        if (nextSlash === -1) {
            throw Error.argument("baseUrl", Sys.Res.badBaseUrl2);
        }
        return baseUrl.substr(0, nextSlash) + url;
    }
    else {
        var lastSlash = baseUrl.lastIndexOf('/');
        if (lastSlash === -1) {
            throw Error.argument("baseUrl", Sys.Res.badBaseUrl3);
        }
        return baseUrl.substr(0, lastSlash+1) + url;
    }
}
Sys.Net.WebRequest._createQueryString = function Sys$Net$WebRequest$_createQueryString(queryString, encodeMethod, addParams) {
    encodeMethod = encodeMethod || encodeURIComponent;
    var i = 0, obj, val, arg, sb = new Sys.StringBuilder();
    if (queryString) {
        for (arg in queryString) {
            obj = queryString[arg];
            if (typeof(obj) === "function") continue;
            val = Sys.Serialization.JavaScriptSerializer.serialize(obj);
            if (i++) {
                sb.append('&');
            }
            sb.append(arg);
            sb.append('=');
            sb.append(encodeMethod(val));
        }
    }
    if (addParams) {
        if (i) {
            sb.append('&');
        }
        sb.append(addParams);
    }
    return sb.toString();
}
Sys.Net.WebRequest._createUrl = function Sys$Net$WebRequest$_createUrl(url, queryString, addParams) {
    if (!queryString && !addParams) {
        return url;
    }
    var qs = Sys.Net.WebRequest._createQueryString(queryString, null, addParams);
    return qs.length
        ? url + ((url && url.indexOf('?') >= 0) ? "&" : "?") + qs
        : url;
}
Sys.Net.WebRequest.registerClass('Sys.Net.WebRequest');
 
Sys._ScriptLoaderTask = function Sys$_ScriptLoaderTask(scriptElement, completedCallback) {
    /// <summary locid="M:J#Sys._ScriptLoaderTask.#ctor" />
    /// <param name="scriptElement" domElement="true"></param>
    /// <param name="completedCallback" type="Function"></param>
    var e = Function._validateParams(arguments, [
        {name: "scriptElement", domElement: true},
        {name: "completedCallback", type: Function}
    ]);
    if (e) throw e;
    this._scriptElement = scriptElement;
    this._completedCallback = completedCallback;
}
    function Sys$_ScriptLoaderTask$get_scriptElement() {
        /// <value domElement="true" locid="P:J#Sys._ScriptLoaderTask.scriptElement"></value>
        if (arguments.length !== 0) throw Error.parameterCount();
        return this._scriptElement;
    }
    function Sys$_ScriptLoaderTask$dispose() {
        if(this._disposed) {
            return;
        }
        this._disposed = true;
        this._removeScriptElementHandlers();
        Sys._ScriptLoaderTask._clearScript(this._scriptElement);
        this._scriptElement = null;
    }
    function Sys$_ScriptLoaderTask$execute() {
        /// <summary locid="M:J#Sys._ScriptLoaderTask.execute" />
        if (arguments.length !== 0) throw Error.parameterCount();
        if (this._ensureReadyStateLoaded()) {
            this._executeInternal();
        }
    }
    function Sys$_ScriptLoaderTask$_executeInternal() {
        this._addScriptElementHandlers();
        var headElements = document.getElementsByTagName('head');
        if (headElements.length === 0) {
             throw new Error.invalidOperation(Sys.Res.scriptLoadFailedNoHead);
        }
        else {
             headElements[0].appendChild(this._scriptElement);
        }
    }
    function Sys$_ScriptLoaderTask$_ensureReadyStateLoaded() {
        if (this._useReadyState() && this._scriptElement.readyState !== 'loaded' && this._scriptElement.readyState !== 'complete') {
            this._scriptDownloadDelegate = Function.createDelegate(this, this._executeInternal);
            $addHandler(this._scriptElement, 'readystatechange', this._scriptDownloadDelegate);
            return false;
        }
        return true;
    }
    function Sys$_ScriptLoaderTask$_addScriptElementHandlers() {
        if (this._scriptDownloadDelegate) {
            $removeHandler(this._scriptElement, 'readystatechange', this._scriptDownloadDelegate);
            this._scriptDownloadDelegate = null;
        }
        this._scriptLoadDelegate = Function.createDelegate(this, this._scriptLoadHandler);
        if (this._useReadyState()) {
            $addHandler(this._scriptElement, 'readystatechange', this._scriptLoadDelegate);
        } else {
            $addHandler(this._scriptElement, 'load', this._scriptLoadDelegate);
        }
        if (this._scriptElement.addEventListener) {
            this._scriptErrorDelegate = Function.createDelegate(this, this._scriptErrorHandler);
            this._scriptElement.addEventListener('error', this._scriptErrorDelegate, false);
        }
    }
    function Sys$_ScriptLoaderTask$_removeScriptElementHandlers() {
        if(this._scriptLoadDelegate) {
            var scriptElement = this.get_scriptElement();
            if (this._scriptDownloadDelegate) {
                $removeHandler(this._scriptElement, 'readystatechange', this._scriptDownloadDelegate);
                this._scriptDownloadDelegate = null;
            }
            if (this._useReadyState() && this._scriptLoadDelegate) {
                $removeHandler(scriptElement, 'readystatechange', this._scriptLoadDelegate);
            }
            else {
                $removeHandler(scriptElement, 'load', this._scriptLoadDelegate);
            }
            if (this._scriptErrorDelegate) {
                this._scriptElement.removeEventListener('error', this._scriptErrorDelegate, false);
                this._scriptErrorDelegate = null;
            }
            this._scriptLoadDelegate = null;
        }
    }
    function Sys$_ScriptLoaderTask$_scriptErrorHandler() {
        if(this._disposed) {
            return;
        }
        
        this._completedCallback(this.get_scriptElement(), false);
    }
    function Sys$_ScriptLoaderTask$_scriptLoadHandler() {
        if(this._disposed) {
            return;
        }
        var scriptElement = this.get_scriptElement();
        if (this._useReadyState() && scriptElement.readyState !== 'complete') {
            return;
        }
        this._completedCallback(scriptElement, true);
    }
    function Sys$_ScriptLoaderTask$_useReadyState() {
        return (Sys.Browser.agent === Sys.Browser.InternetExplorer && (Sys.Browser.version < 9 || ((document.documentMode || 0) < 9)));
    }
Sys._ScriptLoaderTask.prototype = {
    get_scriptElement: Sys$_ScriptLoaderTask$get_scriptElement,
    dispose: Sys$_ScriptLoaderTask$dispose,
    execute: Sys$_ScriptLoaderTask$execute,
    _executeInternal: Sys$_ScriptLoaderTask$_executeInternal,
    _ensureReadyStateLoaded: Sys$_ScriptLoaderTask$_ensureReadyStateLoaded,
    _addScriptElementHandlers: Sys$_ScriptLoaderTask$_addScriptElementHandlers,    
    _removeScriptElementHandlers: Sys$_ScriptLoaderTask$_removeScriptElementHandlers,    
    _scriptErrorHandler: Sys$_ScriptLoaderTask$_scriptErrorHandler,
    _scriptLoadHandler: Sys$_ScriptLoaderTask$_scriptLoadHandler,
    _useReadyState: Sys$_ScriptLoaderTask$_useReadyState
}
Sys._ScriptLoaderTask.registerClass("Sys._ScriptLoaderTask", null, Sys.IDisposable);
Sys._ScriptLoaderTask._clearScript = function Sys$_ScriptLoaderTask$_clearScript(scriptElement) {
    if (!Sys.Debug.isDebug && scriptElement.parentNode) {
        scriptElement.parentNode.removeChild(scriptElement);
    }
}
Type.registerNamespace('Sys.Net');
 
Sys.Net.WebServiceProxy = function Sys$Net$WebServiceProxy() {
}
    function Sys$Net$WebServiceProxy$get_timeout() {
        /// <value type="Number" locid="P:J#Sys.Net.WebServiceProxy.timeout"></value>
        if (arguments.length !== 0) throw Error.parameterCount();
        return this._timeout || 0;
    }
    function Sys$Net$WebServiceProxy$set_timeout(value) {
        var e = Function._validateParams(arguments, [{name: "value", type: Number}]);
        if (e) throw e;
        if (value < 0) { throw Error.argumentOutOfRange('value', value, Sys.Res.invalidTimeout); }
        this._timeout = value;
    }
    function Sys$Net$WebServiceProxy$get_defaultUserContext() {
        /// <value mayBeNull="true" locid="P:J#Sys.Net.WebServiceProxy.defaultUserContext"></value>
        if (arguments.length !== 0) throw Error.parameterCount();
        return (typeof(this._userContext) === "undefined") ? null : this._userContext;
    }
    function Sys$Net$WebServiceProxy$set_defaultUserContext(value) {
        var e = Function._validateParams(arguments, [{name: "value", mayBeNull: true}]);
        if (e) throw e;
        this._userContext = value;
    }
    function Sys$Net$WebServiceProxy$get_defaultSucceededCallback() {
        /// <value type="Function" mayBeNull="true" locid="P:J#Sys.Net.WebServiceProxy.defaultSucceededCallback"></value>
        if (arguments.length !== 0) throw Error.parameterCount();
        return this._succeeded || null;
    }
    function Sys$Net$WebServiceProxy$set_defaultSucceededCallback(value) {
        var e = Function._validateParams(arguments, [{name: "value", type: Function, mayBeNull: true}]);
        if (e) throw e;
        this._succeeded = value;
    }
    function Sys$Net$WebServiceProxy$get_defaultFailedCallback() {
        /// <value type="Function" mayBeNull="true" locid="P:J#Sys.Net.WebServiceProxy.defaultFailedCallback"></value>
        if (arguments.length !== 0) throw Error.parameterCount();
        return this._failed || null;
    }
    function Sys$Net$WebServiceProxy$set_defaultFailedCallback(value) {
        var e = Function._validateParams(arguments, [{name: "value", type: Function, mayBeNull: true}]);
        if (e) throw e;
        this._failed = value;
    }
    function Sys$Net$WebServiceProxy$get_enableJsonp() {
        /// <value type="Boolean" locid="P:J#Sys.Net.WebServiceProxy.enableJsonp"></value>
        if (arguments.length !== 0) throw Error.parameterCount();
        return !!this._jsonp;
    }
    function Sys$Net$WebServiceProxy$set_enableJsonp(value) {
        var e = Function._validateParams(arguments, [{name: "value", type: Boolean}]);
        if (e) throw e;
        this._jsonp = value;
    }
    function Sys$Net$WebServiceProxy$get_path() {
        /// <value type="String" locid="P:J#Sys.Net.WebServiceProxy.path"></value>
        if (arguments.length !== 0) throw Error.parameterCount();
        return this._path || null;
    }
    function Sys$Net$WebServiceProxy$set_path(value) {
        var e = Function._validateParams(arguments, [{name: "value", type: String}]);
        if (e) throw e;
        this._path = value;
    }
    function Sys$Net$WebServiceProxy$get_jsonpCallbackParameter() {
        /// <value type="String" locid="P:J#Sys.Net.WebServiceProxy.jsonpCallbackParameter"></value>
        if (arguments.length !== 0) throw Error.parameterCount();
        return this._callbackParameter || "callback";
    }
    function Sys$Net$WebServiceProxy$set_jsonpCallbackParameter(value) {
        var e = Function._validateParams(arguments, [{name: "value", type: String}]);
        if (e) throw e;
        this._callbackParameter = value;
    }
    function Sys$Net$WebServiceProxy$_invoke(servicePath, methodName, useGet, params, onSuccess, onFailure, userContext) {
        /// <summary locid="M:J#Sys.Net.WebServiceProxy._invoke" />
        /// <param name="servicePath" type="String"></param>
        /// <param name="methodName" type="String"></param>
        /// <param name="useGet" type="Boolean"></param>
        /// <param name="params"></param>
        /// <param name="onSuccess" type="Function" mayBeNull="true" optional="true"></param>
        /// <param name="onFailure" type="Function" mayBeNull="true" optional="true"></param>
        /// <param name="userContext" mayBeNull="true" optional="true"></param>
        /// <returns type="Sys.Net.WebRequest" mayBeNull="true"></returns>
        var e = Function._validateParams(arguments, [
            {name: "servicePath", type: String},
            {name: "methodName", type: String},
            {name: "useGet", type: Boolean},
            {name: "params"},
            {name: "onSuccess", type: Function, mayBeNull: true, optional: true},
            {name: "onFailure", type: Function, mayBeNull: true, optional: true},
            {name: "userContext", mayBeNull: true, optional: true}
        ]);
        if (e) throw e;
        onSuccess = onSuccess || this.get_defaultSucceededCallback();
        onFailure = onFailure || this.get_defaultFailedCallback();
        if (userContext === null || typeof userContext === 'undefined') userContext = this.get_defaultUserContext();
        return Sys.Net.WebServiceProxy.invoke(servicePath, methodName, useGet, params, onSuccess, onFailure, userContext, this.get_timeout(), this.get_enableJsonp(), this.get_jsonpCallbackParameter());
    }
Sys.Net.WebServiceProxy.prototype = {
    get_timeout: Sys$Net$WebServiceProxy$get_timeout,
    set_timeout: Sys$Net$WebServiceProxy$set_timeout,
    get_defaultUserContext: Sys$Net$WebServiceProxy$get_defaultUserContext,
    set_defaultUserContext: Sys$Net$WebServiceProxy$set_defaultUserContext,
    get_defaultSucceededCallback: Sys$Net$WebServiceProxy$get_defaultSucceededCallback,
    set_defaultSucceededCallback: Sys$Net$WebServiceProxy$set_defaultSucceededCallback,
    get_defaultFailedCallback: Sys$Net$WebServiceProxy$get_defaultFailedCallback,
    set_defaultFailedCallback: Sys$Net$WebServiceProxy$set_defaultFailedCallback,
    get_enableJsonp: Sys$Net$WebServiceProxy$get_enableJsonp,
    set_enableJsonp: Sys$Net$WebServiceProxy$set_enableJsonp,
    get_path: Sys$Net$WebServiceProxy$get_path,
    set_path: Sys$Net$WebServiceProxy$set_path,
    get_jsonpCallbackParameter: Sys$Net$WebServiceProxy$get_jsonpCallbackParameter,
    set_jsonpCallbackParameter: Sys$Net$WebServiceProxy$set_jsonpCallbackParameter,
    _invoke: Sys$Net$WebServiceProxy$_invoke
}
Sys.Net.WebServiceProxy.registerClass('Sys.Net.WebServiceProxy');
Sys.Net.WebServiceProxy.invoke = function Sys$Net$WebServiceProxy$invoke(servicePath, methodName, useGet, params, onSuccess, onFailure, userContext, timeout, enableJsonp, jsonpCallbackParameter) {
    /// <summary locid="M:J#Sys.Net.WebServiceProxy.invoke" />
    /// <param name="servicePath" type="String"></param>
    /// <param name="methodName" type="String" mayBeNull="true" optional="true"></param>
    /// <param name="useGet" type="Boolean" optional="true"></param>
    /// <param name="params" mayBeNull="true" optional="true"></param>
    /// <param name="onSuccess" type="Function" mayBeNull="true" optional="true"></param>
    /// <param name="onFailure" type="Function" mayBeNull="true" optional="true"></param>
    /// <param name="userContext" mayBeNull="true" optional="true"></param>
    /// <param name="timeout" type="Number" optional="true"></param>
    /// <param name="enableJsonp" type="Boolean" optional="true" mayBeNull="true"></param>
    /// <param name="jsonpCallbackParameter" type="String" optional="true" mayBeNull="true"></param>
    /// <returns type="Sys.Net.WebRequest" mayBeNull="true"></returns>
    var e = Function._validateParams(arguments, [
        {name: "servicePath", type: String},
        {name: "methodName", type: String, mayBeNull: true, optional: true},
        {name: "useGet", type: Boolean, optional: true},
        {name: "params", mayBeNull: true, optional: true},
        {name: "onSuccess", type: Function, mayBeNull: true, optional: true},
        {name: "onFailure", type: Function, mayBeNull: true, optional: true},
        {name: "userContext", mayBeNull: true, optional: true},
        {name: "timeout", type: Number, optional: true},
        {name: "enableJsonp", type: Boolean, mayBeNull: true, optional: true},
        {name: "jsonpCallbackParameter", type: String, mayBeNull: true, optional: true}
    ]);
    if (e) throw e;
    var schemeHost = (enableJsonp !== false) ? Sys.Net.WebServiceProxy._xdomain.exec(servicePath) : null,
        tempCallback, jsonp = schemeHost && (schemeHost.length === 3) && 
            ((schemeHost[1] !== location.protocol) || (schemeHost[2] !== location.host));
    useGet = jsonp || useGet;
    if (jsonp) {
        jsonpCallbackParameter = jsonpCallbackParameter || "callback";
        tempCallback = "_jsonp" + Sys._jsonp++;
    }
    if (!params) params = {};
    var urlParams = params;
    if (!useGet || !urlParams) urlParams = {};
    var script, error, timeoutcookie = null, loader, body = null,
        url = Sys.Net.WebRequest._createUrl(methodName
            ? (servicePath+"/"+encodeURIComponent(methodName))
            : servicePath, urlParams, jsonp ? (jsonpCallbackParameter + "=Sys." + tempCallback) : null);
    if (jsonp) {
        script = document.createElement("script");
        script.src = url;
        loader = new Sys._ScriptLoaderTask(script, function(script, loaded) {
            if (!loaded || tempCallback) {
                jsonpComplete({ Message: String.format(Sys.Res.webServiceFailedNoMsg, methodName) }, -1);
            }
        });
        function jsonpComplete(data, statusCode) {
            if (timeoutcookie !== null) {
                window.clearTimeout(timeoutcookie);
                timeoutcookie = null;
            }
            loader.dispose();
            delete Sys[tempCallback];
            tempCallback = null; 
            if ((typeof(statusCode) !== "undefined") && (statusCode !== 200)) {
                if (onFailure) {
                    error = new Sys.Net.WebServiceError(false,
                            data.Message || String.format(Sys.Res.webServiceFailedNoMsg, methodName),
                            data.StackTrace || null,
                            data.ExceptionType || null,
                            data);
                    error._statusCode = statusCode;
                    onFailure(error, userContext, methodName);
                }
                else {
                    if (data.StackTrace && data.Message) {
                        error = data.StackTrace + "-- " + data.Message;
                    }
                    else {
                        error = data.StackTrace || data.Message;
                    }
                    error = String.format(error ? Sys.Res.webServiceFailed : Sys.Res.webServiceFailedNoMsg, methodName, error);
                    throw Sys.Net.WebServiceProxy._createFailedError(methodName, String.format(Sys.Res.webServiceFailed, methodName, error));
                }
            }
            else if (onSuccess) {
                onSuccess(data, userContext, methodName);
            }
        }
        Sys[tempCallback] = jsonpComplete;
        loader.execute();
        return null;
    }
    var request = new Sys.Net.WebRequest();
    request.set_url(url);
    request.get_headers()['Content-Type'] = 'application/json; charset=utf-8';
    if (!useGet) {
        body = Sys.Serialization.JavaScriptSerializer.serialize(params);
        if (body === "{}") body = "";
    }
    request.set_body(body);
    request.add_completed(onComplete);
    if (timeout && timeout > 0) request.set_timeout(timeout);
    request.invoke();
    
    function onComplete(response, eventArgs) {
        if (response.get_responseAvailable()) {
            var statusCode = response.get_statusCode();
            var result = null;
           
            try {
                var contentType = response.getResponseHeader("Content-Type");
                if (contentType.startsWith("application/json")) {
                    result = response.get_object();
                }
                else if (contentType.startsWith("text/xml")) {
                    result = response.get_xml();
                }
                else {
                    result = response.get_responseData();
                }
            } catch (ex) {
            }
            var error = response.getResponseHeader("jsonerror");
            var errorObj = (error === "true");
            if (errorObj) {
                if (result) {
                    result = new Sys.Net.WebServiceError(false, result.Message, result.StackTrace, result.ExceptionType, result);
                }
            }
            else if (contentType.startsWith("application/json")) {
                result = (!result || (typeof(result.d) === "undefined")) ? result : result.d;
            }
            if (((statusCode < 200) || (statusCode >= 300)) || errorObj) {
                if (onFailure) {
                    if (!result || !errorObj) {
                        result = new Sys.Net.WebServiceError(false , String.format(Sys.Res.webServiceFailedNoMsg, methodName));
                    }
                    result._statusCode = statusCode;
                    onFailure(result, userContext, methodName);
                }
                else {
                    if (result && errorObj) {
                        error = result.get_exceptionType() + "-- " + result.get_message();
                    }
                    else {
                        error = response.get_responseData();
                    }
                    throw Sys.Net.WebServiceProxy._createFailedError(methodName, String.format(Sys.Res.webServiceFailed, methodName, error));
                }
            }
            else if (onSuccess) {
                onSuccess(result, userContext, methodName);
            }
        }
        else {
            var msg;
            if (response.get_timedOut()) {
                msg = String.format(Sys.Res.webServiceTimedOut, methodName);
            }
            else {
                msg = String.format(Sys.Res.webServiceFailedNoMsg, methodName)
            }
            if (onFailure) {
                onFailure(new Sys.Net.WebServiceError(response.get_timedOut(), msg, "", ""), userContext, methodName);
            }
            else {
                throw Sys.Net.WebServiceProxy._createFailedError(methodName, msg);
            }
        }
    }
    return request;
}
Sys.Net.WebServiceProxy._createFailedError = function Sys$Net$WebServiceProxy$_createFailedError(methodName, errorMessage) {
    var displayMessage = "Sys.Net.WebServiceFailedException: " + errorMessage;
    var e = Error.create(displayMessage, { 'name': 'Sys.Net.WebServiceFailedException', 'methodName': methodName });
    e.popStackFrame();
    return e;
}
Sys.Net.WebServiceProxy._defaultFailedCallback = function Sys$Net$WebServiceProxy$_defaultFailedCallback(err, methodName) {
    var error = err.get_exceptionType() + "-- " + err.get_message();
    throw Sys.Net.WebServiceProxy._createFailedError(methodName, String.format(Sys.Res.webServiceFailed, methodName, error));
}
Sys.Net.WebServiceProxy._generateTypedConstructor = function Sys$Net$WebServiceProxy$_generateTypedConstructor(type) {
    return function(properties) {
        if (properties) {
            for (var name in properties) {
                this[name] = properties[name];
            }
        }
        this.__type = type;
    }
}
Sys._jsonp = 0;
Sys.Net.WebServiceProxy._xdomain = /^\s*([a-zA-Z0-9\+\-\.]+\:)\/\/([^?#\/]+)/;
 
Sys.Net.WebServiceError = function Sys$Net$WebServiceError(timedOut, message, stackTrace, exceptionType, errorObject) {
    /// <summary locid="M:J#Sys.Net.WebServiceError.#ctor" />
    /// <param name="timedOut" type="Boolean"></param>
    /// <param name="message" type="String" mayBeNull="true"></param>
    /// <param name="stackTrace" type="String" mayBeNull="true" optional="true"></param>
    /// <param name="exceptionType" type="String" mayBeNull="true" optional="true"></param>
    /// <param name="errorObject" type="Object" mayBeNull="true" optional="true"></param>
    var e = Function._validateParams(arguments, [
        {name: "timedOut", type: Boolean},
        {name: "message", type: String, mayBeNull: true},
        {name: "stackTrace", type: String, mayBeNull: true, optional: true},
        {name: "exceptionType", type: String, mayBeNull: true, optional: true},
        {name: "errorObject", type: Object, mayBeNull: true, optional: true}
    ]);
    if (e) throw e;
    this._timedOut = timedOut;
    this._message = message;
    this._stackTrace = stackTrace;
    this._exceptionType = exceptionType;
    this._errorObject = errorObject;
    this._statusCode = -1;
}
    function Sys$Net$WebServiceError$get_timedOut() {
        /// <value type="Boolean" locid="P:J#Sys.Net.WebServiceError.timedOut"></value>
        if (arguments.length !== 0) throw Error.parameterCount();
        return this._timedOut;
    }
    function Sys$Net$WebServiceError$get_statusCode() {
        /// <value type="Number" locid="P:J#Sys.Net.WebServiceError.statusCode"></value>
        if (arguments.length !== 0) throw Error.parameterCount();
        return this._statusCode;
    }
    function Sys$Net$WebServiceError$get_message() {
        /// <value type="String" locid="P:J#Sys.Net.WebServiceError.message"></value>
        if (arguments.length !== 0) throw Error.parameterCount();
        return this._message;
    }
    function Sys$Net$WebServiceError$get_stackTrace() {
        /// <value type="String" locid="P:J#Sys.Net.WebServiceError.stackTrace"></value>
        if (arguments.length !== 0) throw Error.parameterCount();
        return this._stackTrace || "";
    }
    function Sys$Net$WebServiceError$get_exceptionType() {
        /// <value type="String" locid="P:J#Sys.Net.WebServiceError.exceptionType"></value>
        if (arguments.length !== 0) throw Error.parameterCount();
        return this._exceptionType || "";
    }
    function Sys$Net$WebServiceError$get_errorObject() {
        /// <value type="Object" locid="P:J#Sys.Net.WebServiceError.errorObject"></value>
        if (arguments.length !== 0) throw Error.parameterCount();
        return this._errorObject || null;
    }
Sys.Net.WebServiceError.prototype = {
    get_timedOut: Sys$Net$WebServiceError$get_timedOut,
    get_statusCode: Sys$Net$WebServiceError$get_statusCode,
    get_message: Sys$Net$WebServiceError$get_message,
    get_stackTrace: Sys$Net$WebServiceError$get_stackTrace,
    get_exceptionType: Sys$Net$WebServiceError$get_exceptionType,
    get_errorObject: Sys$Net$WebServiceError$get_errorObject
}
Sys.Net.WebServiceError.registerClass('Sys.Net.WebServiceError');


Type.registerNamespace('Sys');
Sys.Res={
"argumentInteger":"Value must be an integer.",
"invokeCalledTwice":"Cannot call invoke more than once.",
"webServiceFailed":"The server method \u0027{0}\u0027 failed with the following error: {1}",
"argumentType":"Object cannot be converted to the required type.",
"argumentNull":"Value cannot be null.",
"scriptAlreadyLoaded":"The script \u0027{0}\u0027 has been referenced multiple times. If referencing Microsoft AJAX scripts explicitly, set the MicrosoftAjaxMode property of the ScriptManager to Explicit.",
"scriptDependencyNotFound":"The script \u0027{0}\u0027 failed to load because it is dependent on script \u0027{1}\u0027.",
"formatBadFormatSpecifier":"Format specifier was invalid.",
"requiredScriptReferenceNotIncluded":"\u0027{0}\u0027 requires that you have included a script reference to \u0027{1}\u0027.",
"webServiceFailedNoMsg":"The server method \u0027{0}\u0027 failed.",
"argumentDomElement":"Value must be a DOM element.",
"invalidExecutorType":"Could not create a valid Sys.Net.WebRequestExecutor from: {0}.",
"cannotCallBeforeResponse":"Cannot call {0} when responseAvailable is false.",
"actualValue":"Actual value was {0}.",
"enumInvalidValue":"\u0027{0}\u0027 is not a valid value for enum {1}.",
"scriptLoadFailed":"The script \u0027{0}\u0027 could not be loaded.",
"parameterCount":"Parameter count mismatch.",
"cannotDeserializeEmptyString":"Cannot deserialize empty string.",
"formatInvalidString":"Input string was not in a correct format.",
"invalidTimeout":"Value must be greater than or equal to zero.",
"cannotAbortBeforeStart":"Cannot abort when executor has not started.",
"argument":"Value does not fall within the expected range.",
"cannotDeserializeInvalidJson":"Cannot deserialize. The data does not correspond to valid JSON.",
"invalidHttpVerb":"httpVerb cannot be set to an empty or null string.",
"nullWebRequest":"Cannot call executeRequest with a null webRequest.",
"eventHandlerInvalid":"Handler was not added through the Sys.UI.DomEvent.addHandler method.",
"cannotSerializeNonFiniteNumbers":"Cannot serialize non finite numbers.",
"argumentUndefined":"Value cannot be undefined.",
"webServiceInvalidReturnType":"The server method \u0027{0}\u0027 returned an invalid type. Expected type: {1}",
"servicePathNotSet":"The path to the web service has not been set.",
"argumentTypeWithTypes":"Object of type \u0027{0}\u0027 cannot be converted to type \u0027{1}\u0027.",
"cannotCallOnceStarted":"Cannot call {0} once started.",
"badBaseUrl1":"Base URL does not contain ://.",
"badBaseUrl2":"Base URL does not contain another /.",
"badBaseUrl3":"Cannot find last / in base URL.",
"setExecutorAfterActive":"Cannot set executor after it has become active.",
"paramName":"Parameter name: {0}",
"nullReferenceInPath":"Null reference while evaluating data path: \u0027{0}\u0027.",
"cannotCallOutsideHandler":"Cannot call {0} outside of a completed event handler.",
"cannotSerializeObjectWithCycle":"Cannot serialize object with cyclic reference within child properties.",
"format":"One of the identified items was in an invalid format.",
"assertFailedCaller":"Assertion Failed: {0}\r\nat {1}",
"argumentOutOfRange":"Specified argument was out of the range of valid values.",
"webServiceTimedOut":"The server method \u0027{0}\u0027 timed out.",
"notImplemented":"The method or operation is not implemented.",
"assertFailed":"Assertion Failed: {0}",
"invalidOperation":"Operation is not valid due to the current state of the object.",
"breakIntoDebugger":"{0}\r\n\r\nBreak into debugger?",
"argumentTypeName":"Value is not the name of an existing type.",
"cantBeCalledAfterDispose":"Can\u0027t be called after dispose.",
"componentCantSetIdAfterAddedToApp":"The id property of a component can\u0027t be set after it\u0027s been added to the Application object.",
"behaviorDuplicateName":"A behavior with name \u0027{0}\u0027 already exists or it is the name of an existing property on the target element.",
"notATypeName":"Value is not a valid type name.",
"elementNotFound":"An element with id \u0027{0}\u0027 could not be found.",
"stateMustBeStringDictionary":"The state object can only have null and string fields.",
"boolTrueOrFalse":"Value must be \u0027true\u0027 or \u0027false\u0027.",
"scriptLoadFailedNoHead":"ScriptLoader requires pages to contain a \u003chead\u003e element.",
"stringFormatInvalid":"The format string is invalid.",
"referenceNotFound":"Component \u0027{0}\u0027 was not found.",
"enumReservedName":"\u0027{0}\u0027 is a reserved name that can\u0027t be used as an enum value name.",
"circularParentChain":"The chain of control parents can\u0027t have circular references.",
"namespaceContainsNonObject":"Object {0} already exists and is not an object.",
"undefinedEvent":"\u0027{0}\u0027 is not an event.",
"propertyUndefined":"\u0027{0}\u0027 is not a property or an existing field.",
"observableConflict":"Object already contains a member with the name \u0027{0}\u0027.",
"historyCannotEnableHistory":"Cannot set enableHistory after initialization.",
"scriptLoadFailedDebug":"The script \u0027{0}\u0027 failed to load. Check for:\r\n Inaccessible path.\r\n Script errors. (IE) Enable \u0027Display a notification about every script error\u0027 under advanced settings.",
"propertyNotWritable":"\u0027{0}\u0027 is not a writable property.",
"enumInvalidValueName":"\u0027{0}\u0027 is not a valid name for an enum value.",
"controlAlreadyDefined":"A control is already associated with the element.",
"addHandlerCantBeUsedForError":"Can\u0027t add a handler for the error event using this method. Please set the window.onerror property instead.",
"cantAddNonFunctionhandler":"Can\u0027t add a handler that is not a function.",
"invalidNameSpace":"Value is not a valid namespace identifier.",
"notAnInterface":"Value is not a valid interface.",
"eventHandlerNotFunction":"Handler must be a function.",
"propertyNotAnArray":"\u0027{0}\u0027 is not an Array property.",
"namespaceContainsClass":"Object {0} already exists as a class, enum, or interface.",
"typeRegisteredTwice":"Type {0} has already been registered. The type may be defined multiple times or the script file that defines it may have already been loaded. A possible cause is a change of settings during a partial update.",
"cantSetNameAfterInit":"The name property can\u0027t be set on this object after initialization.",
"historyMissingFrame":"For the history feature to work in IE, the page must have an iFrame element with id \u0027__historyFrame\u0027 pointed to a page that gets its title from the \u0027title\u0027 query string parameter and calls Sys.Application._onIFrameLoad() on the parent window. This can be done by setting EnableHistory to true on ScriptManager.",
"appDuplicateComponent":"Two components with the same id \u0027{0}\u0027 can\u0027t be added to the application.",
"historyCannotAddHistoryPointWithHistoryDisabled":"A history point can only be added if enableHistory is set to true.",
"baseNotAClass":"Value is not a class.",
"expectedElementOrId":"Value must be a DOM element or DOM element Id.",
"methodNotFound":"No method found with name \u0027{0}\u0027.",
"arrayParseBadFormat":"Value must be a valid string representation for an array. It must start with a \u0027[\u0027 and end with a \u0027]\u0027.",
"stateFieldNameInvalid":"State field names must not contain any \u0027=\u0027 characters.",
"cantSetId":"The id property can\u0027t be set on this object.",
"stringFormatBraceMismatch":"The format string contains an unmatched opening or closing brace.",
"enumValueNotInteger":"An enumeration definition can only contain integer values.",
"propertyNullOrUndefined":"Cannot set the properties of \u0027{0}\u0027 because it returned a null value.",
"argumentDomNode":"Value must be a DOM element or a text node.",
"componentCantSetIdTwice":"The id property of a component can\u0027t be set more than once.",
"createComponentOnDom":"Value must be null for Components that are not Controls or Behaviors.",
"createNotComponent":"{0} does not derive from Sys.Component.",
"createNoDom":"Value must not be null for Controls and Behaviors.",
"cantAddWithoutId":"Can\u0027t add a component that doesn\u0027t have an id.",
"urlTooLong":"The history state must be small enough to not make the url larger than {0} characters.",
"notObservable":"Instances of type \u0027{0}\u0027 cannot be observed.",
"badTypeName":"Value is not the name of the type being registered or the name is a reserved word."
};

// Name:        MicrosoftAjaxWebForms.debug.js
// Assembly:    System.Web.Extensions
// Version:     4.0.0.0
// FileVersion: 4.8.4110.0
//-----------------------------------------------------------------------
// Copyright (C) Microsoft Corporation. All rights reserved.
//-----------------------------------------------------------------------
// MicrosoftAjaxWebForms.js
// Microsoft AJAX ASP.NET WebForms Framework.
Type._registerScript("MicrosoftAjaxWebForms.js", [
	"MicrosoftAjaxCore.js",
	"MicrosoftAjaxSerialization.js",
	"MicrosoftAjaxNetwork.js",
	"MicrosoftAjaxComponentModel.js"]);
Type.registerNamespace('Sys.WebForms');
Sys.WebForms.BeginRequestEventArgs = function Sys$WebForms$BeginRequestEventArgs(request, postBackElement, updatePanelsToUpdate) {
    /// <summary locid="M:J#Sys.WebForms.BeginRequestEventArgs.#ctor" />
    /// <param name="request" type="Sys.Net.WebRequest"></param>
    /// <param name="postBackElement" domElement="true" mayBeNull="true"></param>
    /// <param name="updatePanelsToUpdate" type="Array" elementType="String" mayBeNull="true" optional="true"></param>
    var e = Function._validateParams(arguments, [
        {name: "request", type: Sys.Net.WebRequest},
        {name: "postBackElement", mayBeNull: true, domElement: true},
        {name: "updatePanelsToUpdate", type: Array, mayBeNull: true, optional: true, elementType: String}
    ]);
    if (e) throw e;
    Sys.WebForms.BeginRequestEventArgs.initializeBase(this);
    this._request = request;
    this._postBackElement = postBackElement;
    this._updatePanelsToUpdate = updatePanelsToUpdate;
}
    function Sys$WebForms$BeginRequestEventArgs$get_postBackElement() {
        /// <value domElement="true" mayBeNull="true" locid="P:J#Sys.WebForms.BeginRequestEventArgs.postBackElement"></value>
        if (arguments.length !== 0) throw Error.parameterCount();
        return this._postBackElement;
    }
    function Sys$WebForms$BeginRequestEventArgs$get_request() {
        /// <value type="Sys.Net.WebRequest" locid="P:J#Sys.WebForms.BeginRequestEventArgs.request"></value>
        if (arguments.length !== 0) throw Error.parameterCount();
        return this._request;
    }
    function Sys$WebForms$BeginRequestEventArgs$get_updatePanelsToUpdate() {
        /// <value type="Array" elementType="String" locid="P:J#Sys.WebForms.BeginRequestEventArgs.updatePanelsToUpdate"></value>
        if (arguments.length !== 0) throw Error.parameterCount();
        return this._updatePanelsToUpdate ? Array.clone(this._updatePanelsToUpdate) : [];
    }
Sys.WebForms.BeginRequestEventArgs.prototype = {
    get_postBackElement: Sys$WebForms$BeginRequestEventArgs$get_postBackElement,
    get_request: Sys$WebForms$BeginRequestEventArgs$get_request,
    get_updatePanelsToUpdate: Sys$WebForms$BeginRequestEventArgs$get_updatePanelsToUpdate
}
Sys.WebForms.BeginRequestEventArgs.registerClass('Sys.WebForms.BeginRequestEventArgs', Sys.EventArgs);
 
Sys.WebForms.EndRequestEventArgs = function Sys$WebForms$EndRequestEventArgs(error, dataItems, response) {
    /// <summary locid="M:J#Sys.WebForms.EndRequestEventArgs.#ctor" />
    /// <param name="error" type="Error" mayBeNull="true"></param>
    /// <param name="dataItems" type="Object" mayBeNull="true"></param>
    /// <param name="response" type="Sys.Net.WebRequestExecutor"></param>
    var e = Function._validateParams(arguments, [
        {name: "error", type: Error, mayBeNull: true},
        {name: "dataItems", type: Object, mayBeNull: true},
        {name: "response", type: Sys.Net.WebRequestExecutor}
    ]);
    if (e) throw e;
    Sys.WebForms.EndRequestEventArgs.initializeBase(this);
    this._errorHandled = false;
    this._error = error;
    this._dataItems = dataItems || new Object();
    this._response = response;
}
    function Sys$WebForms$EndRequestEventArgs$get_dataItems() {
        /// <value type="Object" locid="P:J#Sys.WebForms.EndRequestEventArgs.dataItems"></value>
        if (arguments.length !== 0) throw Error.parameterCount();
        return this._dataItems;
    }
    function Sys$WebForms$EndRequestEventArgs$get_error() {
        /// <value type="Error" locid="P:J#Sys.WebForms.EndRequestEventArgs.error"></value>
        if (arguments.length !== 0) throw Error.parameterCount();
        return this._error;
    }
    function Sys$WebForms$EndRequestEventArgs$get_errorHandled() {
        /// <value type="Boolean" locid="P:J#Sys.WebForms.EndRequestEventArgs.errorHandled"></value>
        if (arguments.length !== 0) throw Error.parameterCount();
        return this._errorHandled;
    }
    function Sys$WebForms$EndRequestEventArgs$set_errorHandled(value) {
        var e = Function._validateParams(arguments, [{name: "value", type: Boolean}]);
        if (e) throw e;
        this._errorHandled = value;
    }
    function Sys$WebForms$EndRequestEventArgs$get_response() {
        /// <value type="Sys.Net.WebRequestExecutor" locid="P:J#Sys.WebForms.EndRequestEventArgs.response"></value>
        if (arguments.length !== 0) throw Error.parameterCount();
        return this._response;
    }
Sys.WebForms.EndRequestEventArgs.prototype = {
    get_dataItems: Sys$WebForms$EndRequestEventArgs$get_dataItems,
    get_error: Sys$WebForms$EndRequestEventArgs$get_error,
    get_errorHandled: Sys$WebForms$EndRequestEventArgs$get_errorHandled,
    set_errorHandled: Sys$WebForms$EndRequestEventArgs$set_errorHandled,
    get_response: Sys$WebForms$EndRequestEventArgs$get_response
}
Sys.WebForms.EndRequestEventArgs.registerClass('Sys.WebForms.EndRequestEventArgs', Sys.EventArgs);
Sys.WebForms.InitializeRequestEventArgs = function Sys$WebForms$InitializeRequestEventArgs(request, postBackElement, updatePanelsToUpdate) {
    /// <summary locid="M:J#Sys.WebForms.InitializeRequestEventArgs.#ctor" />
    /// <param name="request" type="Sys.Net.WebRequest"></param>
    /// <param name="postBackElement" domElement="true" mayBeNull="true"></param>
    /// <param name="updatePanelsToUpdate" type="Array" elementType="String" mayBeNull="true" optional="true"></param>
    var e = Function._validateParams(arguments, [
        {name: "request", type: Sys.Net.WebRequest},
        {name: "postBackElement", mayBeNull: true, domElement: true},
        {name: "updatePanelsToUpdate", type: Array, mayBeNull: true, optional: true, elementType: String}
    ]);
    if (e) throw e;
    Sys.WebForms.InitializeRequestEventArgs.initializeBase(this);
    this._request = request;
    this._postBackElement = postBackElement;
    this._updatePanelsToUpdate = updatePanelsToUpdate;
}
    function Sys$WebForms$InitializeRequestEventArgs$get_postBackElement() {
        /// <value domElement="true" mayBeNull="true" locid="P:J#Sys.WebForms.InitializeRequestEventArgs.postBackElement"></value>
        if (arguments.length !== 0) throw Error.parameterCount();
        return this._postBackElement;
    }
    function Sys$WebForms$InitializeRequestEventArgs$get_request() {
        /// <value type="Sys.Net.WebRequest" locid="P:J#Sys.WebForms.InitializeRequestEventArgs.request"></value>
        if (arguments.length !== 0) throw Error.parameterCount();
        return this._request;
    }
    function Sys$WebForms$InitializeRequestEventArgs$get_updatePanelsToUpdate() {
        /// <value type="Array" elementType="String" locid="P:J#Sys.WebForms.InitializeRequestEventArgs.updatePanelsToUpdate"></value>
        if (arguments.length !== 0) throw Error.parameterCount();
        return this._updatePanelsToUpdate ? Array.clone(this._updatePanelsToUpdate) : [];
    }
    function Sys$WebForms$InitializeRequestEventArgs$set_updatePanelsToUpdate(value) {
        var e = Function._validateParams(arguments, [{name: "value", type: Array, elementType: String}]);
        if (e) throw e;
        this._updated = true;
        this._updatePanelsToUpdate = value;
    }
Sys.WebForms.InitializeRequestEventArgs.prototype = {
    get_postBackElement: Sys$WebForms$InitializeRequestEventArgs$get_postBackElement,
    get_request: Sys$WebForms$InitializeRequestEventArgs$get_request,
    get_updatePanelsToUpdate: Sys$WebForms$InitializeRequestEventArgs$get_updatePanelsToUpdate,
    set_updatePanelsToUpdate: Sys$WebForms$InitializeRequestEventArgs$set_updatePanelsToUpdate
}
Sys.WebForms.InitializeRequestEventArgs.registerClass('Sys.WebForms.InitializeRequestEventArgs', Sys.CancelEventArgs);
 
Sys.WebForms.PageLoadedEventArgs = function Sys$WebForms$PageLoadedEventArgs(panelsUpdated, panelsCreated, dataItems) {
    /// <summary locid="M:J#Sys.WebForms.PageLoadedEventArgs.#ctor" />
    /// <param name="panelsUpdated" type="Array"></param>
    /// <param name="panelsCreated" type="Array"></param>
    /// <param name="dataItems" type="Object" mayBeNull="true"></param>
    var e = Function._validateParams(arguments, [
        {name: "panelsUpdated", type: Array},
        {name: "panelsCreated", type: Array},
        {name: "dataItems", type: Object, mayBeNull: true}
    ]);
    if (e) throw e;
    Sys.WebForms.PageLoadedEventArgs.initializeBase(this);
    this._panelsUpdated = panelsUpdated;
    this._panelsCreated = panelsCreated;
    this._dataItems = dataItems || new Object();
}
    function Sys$WebForms$PageLoadedEventArgs$get_dataItems() {
        /// <value type="Object" locid="P:J#Sys.WebForms.PageLoadedEventArgs.dataItems"></value>
        if (arguments.length !== 0) throw Error.parameterCount();
        return this._dataItems;
    }
    function Sys$WebForms$PageLoadedEventArgs$get_panelsCreated() {
        /// <value type="Array" locid="P:J#Sys.WebForms.PageLoadedEventArgs.panelsCreated"></value>
        if (arguments.length !== 0) throw Error.parameterCount();
        return this._panelsCreated;
    }
    function Sys$WebForms$PageLoadedEventArgs$get_panelsUpdated() {
        /// <value type="Array" locid="P:J#Sys.WebForms.PageLoadedEventArgs.panelsUpdated"></value>
        if (arguments.length !== 0) throw Error.parameterCount();
        return this._panelsUpdated;
    }
Sys.WebForms.PageLoadedEventArgs.prototype = {
    get_dataItems: Sys$WebForms$PageLoadedEventArgs$get_dataItems,
    get_panelsCreated: Sys$WebForms$PageLoadedEventArgs$get_panelsCreated,
    get_panelsUpdated: Sys$WebForms$PageLoadedEventArgs$get_panelsUpdated
}
Sys.WebForms.PageLoadedEventArgs.registerClass('Sys.WebForms.PageLoadedEventArgs', Sys.EventArgs);
Sys.WebForms.PageLoadingEventArgs = function Sys$WebForms$PageLoadingEventArgs(panelsUpdating, panelsDeleting, dataItems) {
    /// <summary locid="M:J#Sys.WebForms.PageLoadingEventArgs.#ctor" />
    /// <param name="panelsUpdating" type="Array"></param>
    /// <param name="panelsDeleting" type="Array"></param>
    /// <param name="dataItems" type="Object" mayBeNull="true"></param>
    var e = Function._validateParams(arguments, [
        {name: "panelsUpdating", type: Array},
        {name: "panelsDeleting", type: Array},
        {name: "dataItems", type: Object, mayBeNull: true}
    ]);
    if (e) throw e;
    Sys.WebForms.PageLoadingEventArgs.initializeBase(this);
    this._panelsUpdating = panelsUpdating;
    this._panelsDeleting = panelsDeleting;
    this._dataItems = dataItems || new Object();
}
    function Sys$WebForms$PageLoadingEventArgs$get_dataItems() {
        /// <value type="Object" locid="P:J#Sys.WebForms.PageLoadingEventArgs.dataItems"></value>
        if (arguments.length !== 0) throw Error.parameterCount();
        return this._dataItems;
    }
    function Sys$WebForms$PageLoadingEventArgs$get_panelsDeleting() {
        /// <value type="Array" locid="P:J#Sys.WebForms.PageLoadingEventArgs.panelsDeleting"></value>
        if (arguments.length !== 0) throw Error.parameterCount();
        return this._panelsDeleting;
    }
    function Sys$WebForms$PageLoadingEventArgs$get_panelsUpdating() {
        /// <value type="Array" locid="P:J#Sys.WebForms.PageLoadingEventArgs.panelsUpdating"></value>
        if (arguments.length !== 0) throw Error.parameterCount();
        return this._panelsUpdating;
    }
Sys.WebForms.PageLoadingEventArgs.prototype = {
    get_dataItems: Sys$WebForms$PageLoadingEventArgs$get_dataItems,
    get_panelsDeleting: Sys$WebForms$PageLoadingEventArgs$get_panelsDeleting,
    get_panelsUpdating: Sys$WebForms$PageLoadingEventArgs$get_panelsUpdating
}
Sys.WebForms.PageLoadingEventArgs.registerClass('Sys.WebForms.PageLoadingEventArgs', Sys.EventArgs);
 
Sys._ScriptLoader = function Sys$_ScriptLoader() {
    this._scriptsToLoad = null;
    this._sessions = [];
    this._scriptLoadedDelegate = Function.createDelegate(this, this._scriptLoadedHandler);
}
    function Sys$_ScriptLoader$dispose() {
        this._stopSession();
        this._loading = false;
        if(this._events) {
            delete this._events;
        }
        this._sessions = null;
        this._currentSession = null;
        this._scriptLoadedDelegate = null;        
    }
    function Sys$_ScriptLoader$loadScripts(scriptTimeout, allScriptsLoadedCallback, scriptLoadFailedCallback, scriptLoadTimeoutCallback) {
        /// <summary locid="M:J#Sys._ScriptLoader.loadScripts" />
        /// <param name="scriptTimeout" type="Number" integer="true"></param>
        /// <param name="allScriptsLoadedCallback" type="Function" mayBeNull="true"></param>
        /// <param name="scriptLoadFailedCallback" type="Function" mayBeNull="true"></param>
        /// <param name="scriptLoadTimeoutCallback" type="Function" mayBeNull="true"></param>
        var e = Function._validateParams(arguments, [
            {name: "scriptTimeout", type: Number, integer: true},
            {name: "allScriptsLoadedCallback", type: Function, mayBeNull: true},
            {name: "scriptLoadFailedCallback", type: Function, mayBeNull: true},
            {name: "scriptLoadTimeoutCallback", type: Function, mayBeNull: true}
        ]);
        if (e) throw e;
        var session = {
            allScriptsLoadedCallback: allScriptsLoadedCallback,
            scriptLoadFailedCallback: scriptLoadFailedCallback,
            scriptLoadTimeoutCallback: scriptLoadTimeoutCallback,
            scriptsToLoad: this._scriptsToLoad,
            scriptTimeout: scriptTimeout };
        this._scriptsToLoad = null;
        this._sessions[this._sessions.length] = session;
        
        if (!this._loading) {
            this._nextSession();
        }
    }
    function Sys$_ScriptLoader$queueCustomScriptTag(scriptAttributes) {
        /// <summary locid="M:J#Sys._ScriptLoader.queueCustomScriptTag" />
        /// <param name="scriptAttributes" mayBeNull="false"></param>
        var e = Function._validateParams(arguments, [
            {name: "scriptAttributes"}
        ]);
        if (e) throw e;
        if(!this._scriptsToLoad) {
            this._scriptsToLoad = [];
        }
        Array.add(this._scriptsToLoad, scriptAttributes);
    }
    function Sys$_ScriptLoader$queueScriptBlock(scriptContent) {
        /// <summary locid="M:J#Sys._ScriptLoader.queueScriptBlock" />
        /// <param name="scriptContent" type="String" mayBeNull="false"></param>
        var e = Function._validateParams(arguments, [
            {name: "scriptContent", type: String}
        ]);
        if (e) throw e;
        if(!this._scriptsToLoad) {
            this._scriptsToLoad = [];
        }
        Array.add(this._scriptsToLoad, {text: scriptContent});
    }
    function Sys$_ScriptLoader$queueScriptReference(scriptUrl, fallback) {
        /// <summary locid="M:J#Sys._ScriptLoader.queueScriptReference" />
        /// <param name="scriptUrl" type="String" mayBeNull="false"></param>
        /// <param name="fallback" mayBeNull="true" optional="true"></param>
        var e = Function._validateParams(arguments, [
            {name: "scriptUrl", type: String},
            {name: "fallback", mayBeNull: true, optional: true}
        ]);
        if (e) throw e;
        if(!this._scriptsToLoad) {
            this._scriptsToLoad = [];
        }
        Array.add(this._scriptsToLoad, {src: scriptUrl, fallback: fallback});
    }
    function Sys$_ScriptLoader$_createScriptElement(queuedScript) {
        var scriptElement = document.createElement('script');
        scriptElement.type = 'text/javascript';
        for (var attr in queuedScript) {
            scriptElement[attr] = queuedScript[attr];
        }
        
        return scriptElement;
    }
    function Sys$_ScriptLoader$_loadScriptsInternal() {
        var session = this._currentSession;
        if (session.scriptsToLoad && session.scriptsToLoad.length > 0) {
            var nextScript = Array.dequeue(session.scriptsToLoad);
            var onLoad = this._scriptLoadedDelegate;
            if (nextScript.fallback) {
                var fallback = nextScript.fallback;
                delete nextScript.fallback;
                
                var self = this;
                onLoad = function(scriptElement, loaded) {
                    loaded || (function() {
                        var fallbackScriptElement = self._createScriptElement({src: fallback});
                        self._currentTask = new Sys._ScriptLoaderTask(fallbackScriptElement, self._scriptLoadedDelegate);
                        self._currentTask.execute();
                    })();
                };
            }            
            var scriptElement = this._createScriptElement(nextScript);
            
            if (scriptElement.text && Sys.Browser.agent === Sys.Browser.Safari) {
                scriptElement.innerHTML = scriptElement.text;
                delete scriptElement.text;
            }            
            if (typeof(nextScript.src) === "string") {
                this._currentTask = new Sys._ScriptLoaderTask(scriptElement, onLoad);
                this._currentTask.execute();
            }
            else {
                var headElements = document.getElementsByTagName('head');
                if (headElements.length === 0) {
                     throw new Error.invalidOperation(Sys.Res.scriptLoadFailedNoHead);
                }
                else {
                     headElements[0].appendChild(scriptElement);
                }
                
                
                Sys._ScriptLoaderTask._clearScript(scriptElement);
                this._loadScriptsInternal();
            }
        }
        else {
            this._stopSession();
            var callback = session.allScriptsLoadedCallback;
            if(callback) {
                callback(this);
            }
            this._nextSession();
        }
    }
    function Sys$_ScriptLoader$_nextSession() {
        if (this._sessions.length === 0) {
            this._loading = false;
            this._currentSession = null;
            return;
        }
        this._loading = true;
        
        var session = Array.dequeue(this._sessions);
        this._currentSession = session;
        this._loadScriptsInternal();
    }
    function Sys$_ScriptLoader$_raiseError() {
        var callback = this._currentSession.scriptLoadFailedCallback;
        var scriptElement = this._currentTask.get_scriptElement();
        this._stopSession();
        
        if(callback) {
            callback(this, scriptElement);
            this._nextSession();
        }
        else {
            this._loading = false;
            throw Sys._ScriptLoader._errorScriptLoadFailed(scriptElement.src);
        }
    }
    function Sys$_ScriptLoader$_scriptLoadedHandler(scriptElement, loaded) {
        if (loaded) {
            Array.add(Sys._ScriptLoader._getLoadedScripts(), scriptElement.src);
            this._currentTask.dispose();
            this._currentTask = null;
            this._loadScriptsInternal();
        }
        else {
            this._raiseError();
        }
    }
    function Sys$_ScriptLoader$_stopSession() {
        if(this._currentTask) {
            this._currentTask.dispose();
            this._currentTask = null;
        }
    }
Sys._ScriptLoader.prototype = {
    dispose: Sys$_ScriptLoader$dispose,
    loadScripts: Sys$_ScriptLoader$loadScripts,
    queueCustomScriptTag: Sys$_ScriptLoader$queueCustomScriptTag,
    queueScriptBlock: Sys$_ScriptLoader$queueScriptBlock,
    queueScriptReference: Sys$_ScriptLoader$queueScriptReference,
    _createScriptElement: Sys$_ScriptLoader$_createScriptElement,
    _loadScriptsInternal: Sys$_ScriptLoader$_loadScriptsInternal,
    _nextSession: Sys$_ScriptLoader$_nextSession,
    _raiseError: Sys$_ScriptLoader$_raiseError,
    _scriptLoadedHandler: Sys$_ScriptLoader$_scriptLoadedHandler,
    _stopSession: Sys$_ScriptLoader$_stopSession    
}
Sys._ScriptLoader.registerClass('Sys._ScriptLoader', null, Sys.IDisposable);
Sys._ScriptLoader.getInstance = function Sys$_ScriptLoader$getInstance() {
    var sl = Sys._ScriptLoader._activeInstance;
    if(!sl) {
        sl = Sys._ScriptLoader._activeInstance = new Sys._ScriptLoader();
    }
    return sl;
}
Sys._ScriptLoader.isScriptLoaded = function Sys$_ScriptLoader$isScriptLoaded(scriptSrc) {
    var dummyScript = document.createElement('script');
    dummyScript.src = scriptSrc;
    return Array.contains(Sys._ScriptLoader._getLoadedScripts(), dummyScript.src);
}
Sys._ScriptLoader.readLoadedScripts = function Sys$_ScriptLoader$readLoadedScripts() {
    if(!Sys._ScriptLoader._referencedScripts) {
        var referencedScripts = Sys._ScriptLoader._referencedScripts = [];
        var existingScripts = document.getElementsByTagName('script');
        for (var i = existingScripts.length - 1; i >= 0; i--) {
            var scriptNode = existingScripts[i];
            var scriptSrc = scriptNode.src;
            if (scriptSrc.length) {
                if (!Array.contains(referencedScripts, scriptSrc)) {
                    Array.add(referencedScripts, scriptSrc);
                }
            }
        }
    }
}
Sys._ScriptLoader._errorScriptLoadFailed = function Sys$_ScriptLoader$_errorScriptLoadFailed(scriptUrl) {
    var errorMessage;
    errorMessage = Sys.Res.scriptLoadFailedDebug;
    var displayMessage = "Sys.ScriptLoadFailedException: " + String.format(errorMessage, scriptUrl);
    var e = Error.create(displayMessage, {name: 'Sys.ScriptLoadFailedException', 'scriptUrl': scriptUrl });
    e.popStackFrame();
    return e;
}
Sys._ScriptLoader._getLoadedScripts = function Sys$_ScriptLoader$_getLoadedScripts() {
    if(!Sys._ScriptLoader._referencedScripts) {
        Sys._ScriptLoader._referencedScripts = [];
        Sys._ScriptLoader.readLoadedScripts();
    }
    return Sys._ScriptLoader._referencedScripts;
}
 
Sys.WebForms.PageRequestManager = function Sys$WebForms$PageRequestManager() {
    this._form = null;
    this._activeDefaultButton = null;
    this._activeDefaultButtonClicked = false;
    this._updatePanelIDs = null;
    this._updatePanelClientIDs = null;
    this._updatePanelHasChildrenAsTriggers = null;
    this._asyncPostBackControlIDs = null;
    this._asyncPostBackControlClientIDs = null;
    this._postBackControlIDs = null;
    this._postBackControlClientIDs = null;
    this._scriptManagerID = null;
    this._pageLoadedHandler = null;
    this._additionalInput = null;
    this._onsubmit = null;
    this._onSubmitStatements = [];
    this._originalDoPostBack = null;
    this._originalDoPostBackWithOptions = null;
    this._originalFireDefaultButton = null;
    this._originalDoCallback = null;
    this._isCrossPost = false;
    this._postBackSettings = null;
    this._request = null;
    this._onFormSubmitHandler = null;
    this._onFormElementClickHandler = null;
    this._onWindowUnloadHandler = null;
    this._asyncPostBackTimeout = null;
    this._controlIDToFocus = null;
    this._scrollPosition = null;
    this._processingRequest = false;
    this._scriptDisposes = {};
    
    this._transientFields = ["__VIEWSTATEENCRYPTED", "__VIEWSTATEFIELDCOUNT"];
    this._textTypes = /^(text|password|hidden|search|tel|url|email|number|range|color|datetime|date|month|week|time|datetime-local)$/i;
}
    function Sys$WebForms$PageRequestManager$_get_eventHandlerList() {
        if (!this._events) {
            this._events = new Sys.EventHandlerList();
        }
        return this._events;
    }
    function Sys$WebForms$PageRequestManager$get_isInAsyncPostBack() {
        /// <value type="Boolean" locid="P:J#Sys.WebForms.PageRequestManager.isInAsyncPostBack"></value>
        if (arguments.length !== 0) throw Error.parameterCount();
        return this._request !== null;
    }
    function Sys$WebForms$PageRequestManager$add_beginRequest(handler) {
        /// <summary locid="E:J#Sys.WebForms.PageRequestManager.beginRequest" />
        var e = Function._validateParams(arguments, [{name: "handler", type: Function}]);
        if (e) throw e;
        this._get_eventHandlerList().addHandler("beginRequest", handler);
    }
    function Sys$WebForms$PageRequestManager$remove_beginRequest(handler) {
        var e = Function._validateParams(arguments, [{name: "handler", type: Function}]);
        if (e) throw e;
        this._get_eventHandlerList().removeHandler("beginRequest", handler);
    }
    function Sys$WebForms$PageRequestManager$add_endRequest(handler) {
        /// <summary locid="E:J#Sys.WebForms.PageRequestManager.endRequest" />
        var e = Function._validateParams(arguments, [{name: "handler", type: Function}]);
        if (e) throw e;
        this._get_eventHandlerList().addHandler("endRequest", handler);
    }
    function Sys$WebForms$PageRequestManager$remove_endRequest(handler) {
        var e = Function._validateParams(arguments, [{name: "handler", type: Function}]);
        if (e) throw e;
        this._get_eventHandlerList().removeHandler("endRequest", handler);
    }
    function Sys$WebForms$PageRequestManager$add_initializeRequest(handler) {
        /// <summary locid="E:J#Sys.WebForms.PageRequestManager.initializeRequest" />
        var e = Function._validateParams(arguments, [{name: "handler", type: Function}]);
        if (e) throw e;
        this._get_eventHandlerList().addHandler("initializeRequest", handler);
    }
    function Sys$WebForms$PageRequestManager$remove_initializeRequest(handler) {
        var e = Function._validateParams(arguments, [{name: "handler", type: Function}]);
        if (e) throw e;
        this._get_eventHandlerList().removeHandler("initializeRequest", handler);
    }
    function Sys$WebForms$PageRequestManager$add_pageLoaded(handler) {
        /// <summary locid="E:J#Sys.WebForms.PageRequestManager.pageLoaded" />
        var e = Function._validateParams(arguments, [{name: "handler", type: Function}]);
        if (e) throw e;
        this._get_eventHandlerList().addHandler("pageLoaded", handler);
    }
    function Sys$WebForms$PageRequestManager$remove_pageLoaded(handler) {
        var e = Function._validateParams(arguments, [{name: "handler", type: Function}]);
        if (e) throw e;
        this._get_eventHandlerList().removeHandler("pageLoaded", handler);
    }
    function Sys$WebForms$PageRequestManager$add_pageLoading(handler) {
        /// <summary locid="E:J#Sys.WebForms.PageRequestManager.pageLoading" />
        var e = Function._validateParams(arguments, [{name: "handler", type: Function}]);
        if (e) throw e;
        this._get_eventHandlerList().addHandler("pageLoading", handler);
    }
    function Sys$WebForms$PageRequestManager$remove_pageLoading(handler) {
        var e = Function._validateParams(arguments, [{name: "handler", type: Function}]);
        if (e) throw e;
        this._get_eventHandlerList().removeHandler("pageLoading", handler);
    }
    function Sys$WebForms$PageRequestManager$abortPostBack() {
        if (!this._processingRequest && this._request) {
            this._request.get_executor().abort();
            this._request = null;
        }
    }
    function Sys$WebForms$PageRequestManager$beginAsyncPostBack(updatePanelsToUpdate, eventTarget, eventArgument, causesValidation, validationGroup) {
        /// <summary locid="M:J#Sys.WebForms.PageRequestManager.beginAsyncPostBack" />
        /// <param name="updatePanelsToUpdate" type="Array" elementType="String" mayBeNull="true" optional="true"></param>
        /// <param name="eventTarget" type="String" mayBeNull="true" optional="true"></param>
        /// <param name="eventArgument" type="String" mayBeNull="true" optional="true"></param>
        /// <param name="causesValidation" type="Boolean" mayBeNull="true" optional="true"></param>
        /// <param name="validationGroup" type="String" mayBeNull="true" optional="true"></param>
        var e = Function._validateParams(arguments, [
            {name: "updatePanelsToUpdate", type: Array, mayBeNull: true, optional: true, elementType: String},
            {name: "eventTarget", type: String, mayBeNull: true, optional: true},
            {name: "eventArgument", type: String, mayBeNull: true, optional: true},
            {name: "causesValidation", type: Boolean, mayBeNull: true, optional: true},
            {name: "validationGroup", type: String, mayBeNull: true, optional: true}
        ]);
        if (e) throw e;
        if (causesValidation && (typeof(Page_ClientValidate) === 'function') && !Page_ClientValidate(validationGroup || null)) {
            return;
        }
        this._postBackSettings = this._createPostBackSettings(true, updatePanelsToUpdate, eventTarget);
        var form = this._form;
        form.__EVENTTARGET.value = (eventTarget || "");
        form.__EVENTARGUMENT.value = (eventArgument || "");
        this._isCrossPost = false;
        this._additionalInput = null;
        this._onFormSubmit();
    }
    function Sys$WebForms$PageRequestManager$_cancelPendingCallbacks() {
        for (var i = 0, l = window.__pendingCallbacks.length; i < l; i++) {
            var callback = window.__pendingCallbacks[i];
            if (callback) {
                if (!callback.async) {
                    window.__synchronousCallBackIndex = -1;
                }
                window.__pendingCallbacks[i] = null;
                var callbackFrameID = "__CALLBACKFRAME" + i;
                var xmlRequestFrame = document.getElementById(callbackFrameID);
                if (xmlRequestFrame) {
                    xmlRequestFrame.parentNode.removeChild(xmlRequestFrame);
                }
            }
        }
    }
    function Sys$WebForms$PageRequestManager$_commitControls(updatePanelData, asyncPostBackTimeout) {
        if (updatePanelData) {
            this._updatePanelIDs = updatePanelData.updatePanelIDs;
            this._updatePanelClientIDs = updatePanelData.updatePanelClientIDs;
            this._updatePanelHasChildrenAsTriggers = updatePanelData.updatePanelHasChildrenAsTriggers;
            this._asyncPostBackControlIDs = updatePanelData.asyncPostBackControlIDs;
            this._asyncPostBackControlClientIDs = updatePanelData.asyncPostBackControlClientIDs;
            this._postBackControlIDs = updatePanelData.postBackControlIDs;
            this._postBackControlClientIDs = updatePanelData.postBackControlClientIDs;
        }
        if (typeof(asyncPostBackTimeout) !== 'undefined' && asyncPostBackTimeout !== null) {
            this._asyncPostBackTimeout = asyncPostBackTimeout * 1000;
        }
    }
    function Sys$WebForms$PageRequestManager$_createHiddenField(id, value) {
        var container, field = document.getElementById(id);
        if (field) {
            if (!field._isContained) {
                field.parentNode.removeChild(field);
            }
            else {
                container = field.parentNode;
            }
        }
        if (!container) {
            container = document.createElement('span');
            container.style.cssText = "display:none !important";
            this._form.appendChild(container);
        }
        container.innerHTML = "<input type='hidden' />";
        field = container.childNodes[0];
        field._isContained = true;
        field.id = field.name = id;
        field.value = value;
    }
    function Sys$WebForms$PageRequestManager$_createPageRequestManagerTimeoutError() {
        var displayMessage = "Sys.WebForms.PageRequestManagerTimeoutException: " + Sys.WebForms.Res.PRM_TimeoutError;
        var e = Error.create(displayMessage, {name: 'Sys.WebForms.PageRequestManagerTimeoutException'});
        e.popStackFrame();
        return e;
    }
    function Sys$WebForms$PageRequestManager$_createPageRequestManagerServerError(httpStatusCode, message) {
        var displayMessage = "Sys.WebForms.PageRequestManagerServerErrorException: " +
            (message || String.format(Sys.WebForms.Res.PRM_ServerError, httpStatusCode));
        var e = Error.create(displayMessage, {
            name: 'Sys.WebForms.PageRequestManagerServerErrorException',
            httpStatusCode: httpStatusCode
        });
        e.popStackFrame();
        return e;
    }
    function Sys$WebForms$PageRequestManager$_createPageRequestManagerParserError(parserErrorMessage) {
        var displayMessage = "Sys.WebForms.PageRequestManagerParserErrorException: " + String.format(Sys.WebForms.Res.PRM_ParserError, parserErrorMessage);
        var e = Error.create(displayMessage, {name: 'Sys.WebForms.PageRequestManagerParserErrorException'});
        e.popStackFrame();
        return e;
    }
    function Sys$WebForms$PageRequestManager$_createPanelID(panelsToUpdate, postBackSettings) {
        var asyncTarget = postBackSettings.asyncTarget,
            toUpdate = this._ensureUniqueIds(panelsToUpdate || postBackSettings.panelsToUpdate),
            panelArg = (toUpdate instanceof Array)
                ? toUpdate.join(',')
                : (toUpdate || this._scriptManagerID);
        if (asyncTarget) {
            panelArg += "|" + asyncTarget;
        }
        return encodeURIComponent(this._scriptManagerID) + '=' + encodeURIComponent(panelArg) + '&';
    }
    function Sys$WebForms$PageRequestManager$_createPostBackSettings(async, panelsToUpdate, asyncTarget, sourceElement) {
        return { async:async, asyncTarget: asyncTarget, panelsToUpdate: panelsToUpdate, sourceElement: sourceElement };
    }
    function Sys$WebForms$PageRequestManager$_convertToClientIDs(source, destinationIDs, destinationClientIDs, version4) {
        if (source) {
            for (var i = 0, l = source.length; i < l; i += (version4 ? 2 : 1)) {
                var uniqueID = source[i],
                    clientID = (version4 ? source[i+1] : "") || this._uniqueIDToClientID(uniqueID);
                Array.add(destinationIDs, uniqueID);
                Array.add(destinationClientIDs, clientID);
            }
        }
    }
    function Sys$WebForms$PageRequestManager$dispose() {
        if (this._form) {
            Sys.UI.DomEvent.removeHandler(this._form, 'submit', this._onFormSubmitHandler);
            Sys.UI.DomEvent.removeHandler(this._form, 'click', this._onFormElementClickHandler);
            Sys.UI.DomEvent.removeHandler(window, 'unload', this._onWindowUnloadHandler);
            Sys.UI.DomEvent.removeHandler(window, 'load', this._pageLoadedHandler);
        }
        if (this._originalDoPostBack) {
            window.__doPostBack = this._originalDoPostBack;
            this._originalDoPostBack = null;
        }
        if (this._originalDoPostBackWithOptions) {
            window.WebForm_DoPostBackWithOptions = this._originalDoPostBackWithOptions;
            this._originalDoPostBackWithOptions = null;
        }
        if (this._originalFireDefaultButton) {
            window.WebForm_FireDefaultButton = this._originalFireDefaultButton;
            this._originalFireDefaultButton = null;
        }
        if (this._originalDoCallback) {
            window.WebForm_DoCallback = this._originalDoCallback;
            this._originalDoCallback = null;
        }
        this._form = null;
        this._updatePanelIDs = null;
        this._updatePanelClientIDs = null;
        this._asyncPostBackControlIDs = null;
        this._asyncPostBackControlClientIDs = null;
        this._postBackControlIDs = null;
        this._postBackControlClientIDs = null;
        this._asyncPostBackTimeout = null;
        this._scrollPosition = null;
        this._activeElement = null;
    }
    function Sys$WebForms$PageRequestManager$_doCallback(eventTarget, eventArgument, eventCallback, context, errorCallback, useAsync) {
        if (!this.get_isInAsyncPostBack()) {
            this._originalDoCallback(eventTarget, eventArgument, eventCallback, context, errorCallback, useAsync);
        }
    }
    function Sys$WebForms$PageRequestManager$_doPostBack(eventTarget, eventArgument) {
        var event = window.event;
        if (!event) {
            var caller = arguments.callee ? arguments.callee.caller : null;
            if (caller) {
                var recursionLimit = 30;
                while (caller.arguments.callee.caller && --recursionLimit) {
                    caller = caller.arguments.callee.caller;
                }
                event = (recursionLimit && caller.arguments.length) ? caller.arguments[0] : null;
            }
        }
        this._additionalInput = null;
        var form = this._form;
        if ((eventTarget === null) || (typeof(eventTarget) === "undefined") || (this._isCrossPost)) {
            this._postBackSettings = this._createPostBackSettings(false);
            this._isCrossPost = false;
        }
        else {
            var mpUniqueID = this._masterPageUniqueID;
            var clientID = this._uniqueIDToClientID(eventTarget);
            var postBackElement = document.getElementById(clientID);
            if (!postBackElement && mpUniqueID) {
                if (eventTarget.indexOf(mpUniqueID + "$") === 0) {
                    postBackElement = document.getElementById(clientID.substr(mpUniqueID.length + 1));
                }
            }
            if (!postBackElement) {
                if (Array.contains(this._asyncPostBackControlIDs, eventTarget)) {
                    this._postBackSettings = this._createPostBackSettings(true, null, eventTarget);
                }
                else {
                    if (Array.contains(this._postBackControlIDs, eventTarget)) {
                        this._postBackSettings = this._createPostBackSettings(false);
                    }
                    else {
                        var nearestUniqueIDMatch = this._findNearestElement(eventTarget);
                        if (nearestUniqueIDMatch) {
                            this._postBackSettings = this._getPostBackSettings(nearestUniqueIDMatch, eventTarget);
                        }
                        else {
                            if (mpUniqueID) {
                                mpUniqueID += "$";
                                if (eventTarget.indexOf(mpUniqueID) === 0) {
                                    nearestUniqueIDMatch = this._findNearestElement(eventTarget.substr(mpUniqueID.length));
                                }
                            }
                            if (nearestUniqueIDMatch) {
                                this._postBackSettings = this._getPostBackSettings(nearestUniqueIDMatch, eventTarget);
                            }
                            else {
                                var activeElement;
                                try {
                                    activeElement = event ? (event.target || event.srcElement) : null;
                                }
                                catch(ex) {
                                }
                                activeElement = activeElement || this._activeElement;
                                var causesPostback = /__doPostBack\(|WebForm_DoPostBackWithOptions\(/;
                                function testCausesPostBack(attr) {
                                    attr = attr ? attr.toString() : "";
                                    return (causesPostback.test(attr) &&
                                        (attr.indexOf("'" + eventTarget + "'") !== -1) || (attr.indexOf('"' + eventTarget + '"') !== -1));
                                }
                                if (activeElement && (
                                        (activeElement.name === eventTarget) ||
                                        testCausesPostBack(activeElement.href) ||
                                        testCausesPostBack(activeElement.onclick) ||
                                        testCausesPostBack(activeElement.onchange)
                                        )) {
                                    this._postBackSettings = this._getPostBackSettings(activeElement, eventTarget);
                                }
                                else {
                                    this._postBackSettings = this._createPostBackSettings(false);
                                }
                            }
                        }
                    }
                }
            }
            else {
                this._postBackSettings = this._getPostBackSettings(postBackElement, eventTarget);
            }
        }
        if (!this._postBackSettings.async) {
            form.onsubmit = this._onsubmit;
            this._originalDoPostBack(eventTarget, eventArgument);
            form.onsubmit = null;
            return;
        }
        form.__EVENTTARGET.value = eventTarget;
        form.__EVENTARGUMENT.value = eventArgument;
        this._onFormSubmit();
    }
    function Sys$WebForms$PageRequestManager$_doPostBackWithOptions(options) {
        this._isCrossPost = options && options.actionUrl;
        var validationResult = true;
        if (options.validation) {
            if (typeof(Page_ClientValidate) == 'function') {
                validationResult = Page_ClientValidate(options.validationGroup);
            }
        }
        if (validationResult) {
            if ((typeof(options.actionUrl) != "undefined") && (options.actionUrl != null) && (options.actionUrl.length > 0)) {
                theForm.action = options.actionUrl;
            }
            if (options.trackFocus) {
                var lastFocus = theForm.elements["__LASTFOCUS"];
                if ((typeof(lastFocus) != "undefined") && (lastFocus != null)) {
                    if (typeof(document.activeElement) == "undefined") {
                        lastFocus.value = options.eventTarget;
                    }
                    else {
                        var active = document.activeElement;
                        if ((typeof(active) != "undefined") && (active != null)) {
                            if ((typeof(active.id) != "undefined") && (active.id != null) && (active.id.length > 0)) {
                                lastFocus.value = active.id;
                            }
                            else if (typeof(active.name) != "undefined") {
                                lastFocus.value = active.name;
                            }
                        }
                    }
                }
            }
        }
        if (options.clientSubmit) {
            this._doPostBack(options.eventTarget, options.eventArgument);
        }
    }
    function Sys$WebForms$PageRequestManager$_elementContains(container, element) {
        while (element) {
            if (element === container) {
                return true;
            }
            element = element.parentNode;
        }
        return false;
    }
    function Sys$WebForms$PageRequestManager$_endPostBack(error, executor, data) {
        if (this._request === executor.get_webRequest()) {
            this._processingRequest = false;
            this._additionalInput = null;
            this._request = null;
        }
        var handler = this._get_eventHandlerList().getHandler("endRequest");
        var errorHandled = false;
        if (handler) {
            var eventArgs = new Sys.WebForms.EndRequestEventArgs(error, data ? data.dataItems : {}, executor);
            handler(this, eventArgs);
            errorHandled = eventArgs.get_errorHandled();
        }
        if (error && !errorHandled) {
            throw error;
        }
    }
    function Sys$WebForms$PageRequestManager$_ensureUniqueIds(ids) {
        if (!ids) return ids;
        ids = ids instanceof Array ? ids : [ids];
        var uniqueIds = [];
        for (var i = 0, l = ids.length; i < l; i++) {
            var id = ids[i], index = Array.indexOf(this._updatePanelClientIDs, id);
            uniqueIds.push(index > -1 ? this._updatePanelIDs[index] : id);
        }
        return uniqueIds;
    }
    function Sys$WebForms$PageRequestManager$_findNearestElement(uniqueID) {
        while (uniqueID.length > 0) {
            var clientID = this._uniqueIDToClientID(uniqueID);
            var element = document.getElementById(clientID);
            if (element) {
                return element;
            }
            var indexOfLastDollar = uniqueID.lastIndexOf('$');
            if (indexOfLastDollar === -1) {
                return null;
            }
            uniqueID = uniqueID.substring(0, indexOfLastDollar);
        }
        return null;
    }
    function Sys$WebForms$PageRequestManager$_findText(text, location) {
        var startIndex = Math.max(0, location - 20);
        var endIndex = Math.min(text.length, location + 20);
        return text.substring(startIndex, endIndex);
    }
    function Sys$WebForms$PageRequestManager$_fireDefaultButton(event, target) {
        if (event.keyCode === 13) {
            var src = event.srcElement || event.target;
            if (!src || (src.tagName.toLowerCase() !== "textarea")) {
                var defaultButton = document.getElementById(target);
                if (defaultButton && (typeof(defaultButton.click) !== "undefined")) {
                    
                    
                    this._activeDefaultButton = defaultButton;
                    this._activeDefaultButtonClicked = false;
                    try {
                        defaultButton.click();
                    }
                    finally {
                        this._activeDefaultButton = null;
                    }
                    
                    
                    event.cancelBubble = true;
                    if (typeof(event.stopPropagation) === "function") {
                        event.stopPropagation();
                    }
                    return false;
                }
            }
        }
        return true;
    }
    function Sys$WebForms$PageRequestManager$_getPageLoadedEventArgs(initialLoad, data) {
        var updated = [];
        var created = [];
        var version4 = data ? data.version4 : false;
        var upData = data ? data.updatePanelData : null;
        var newIDs, newClientIDs, childIDs, refreshedIDs;
        if (!upData) {
            newIDs = this._updatePanelIDs;
            newClientIDs = this._updatePanelClientIDs;
            childIDs = null;
            refreshedIDs = null;
        }
        else {
            newIDs = upData.updatePanelIDs;
            newClientIDs = upData.updatePanelClientIDs;
            childIDs = upData.childUpdatePanelIDs;
            refreshedIDs = upData.panelsToRefreshIDs;
        }
        var i, l, uniqueID, clientID;
        if (refreshedIDs) {
            for (i = 0, l = refreshedIDs.length; i < l; i += (version4 ? 2 : 1)) {
                uniqueID = refreshedIDs[i];
                clientID = (version4 ? refreshedIDs[i+1] : "") || this._uniqueIDToClientID(uniqueID);
                Array.add(updated, document.getElementById(clientID));
            }
        }
        for (i = 0, l = newIDs.length; i < l; i++) {
            if (initialLoad || Array.indexOf(childIDs, newIDs[i]) !== -1) {
                Array.add(created, document.getElementById(newClientIDs[i]));
            }
        }
        return new Sys.WebForms.PageLoadedEventArgs(updated, created, data ? data.dataItems : {});
    }
    function Sys$WebForms$PageRequestManager$_getPageLoadingEventArgs(data) {
        var updated = [],
            deleted = [],
            upData = data.updatePanelData,
            oldIDs = upData.oldUpdatePanelIDs,
            oldClientIDs = upData.oldUpdatePanelClientIDs,
            newIDs = upData.updatePanelIDs,
            childIDs = upData.childUpdatePanelIDs,
            refreshedIDs = upData.panelsToRefreshIDs,
            i, l, uniqueID, clientID,
            version4 = data.version4;
        for (i = 0, l = refreshedIDs.length; i < l; i += (version4 ? 2 : 1)) {
            uniqueID = refreshedIDs[i];
            clientID = (version4 ? refreshedIDs[i+1] : "") || this._uniqueIDToClientID(uniqueID);
            Array.add(updated, document.getElementById(clientID));
        }
        for (i = 0, l = oldIDs.length; i < l; i++) {
            uniqueID = oldIDs[i];
            if (Array.indexOf(refreshedIDs, uniqueID) === -1 &&
                (Array.indexOf(newIDs, uniqueID) === -1 || Array.indexOf(childIDs, uniqueID) > -1)) {
                Array.add(deleted, document.getElementById(oldClientIDs[i]));
            }
        }
        return new Sys.WebForms.PageLoadingEventArgs(updated, deleted, data.dataItems);
    }
    function Sys$WebForms$PageRequestManager$_getPostBackSettings(element, elementUniqueID) {
        var originalElement = element;
        var proposedSettings = null;
        while (element) {
            if (element.id) {
                if (!proposedSettings && Array.contains(this._asyncPostBackControlClientIDs, element.id)) {
                    proposedSettings = this._createPostBackSettings(true, null, elementUniqueID, originalElement);
                }
                else {
                    if (!proposedSettings && Array.contains(this._postBackControlClientIDs, element.id)) {
                        return this._createPostBackSettings(false);
                    }
                    else {
                        var indexOfPanel = Array.indexOf(this._updatePanelClientIDs, element.id);
                        if (indexOfPanel !== -1) {
                            if (this._updatePanelHasChildrenAsTriggers[indexOfPanel]) {
                                return this._createPostBackSettings(true, [this._updatePanelIDs[indexOfPanel]], elementUniqueID, originalElement);
                            }
                            else {
                                return this._createPostBackSettings(true, null, elementUniqueID, originalElement);
                            }
                        }
                    }
                }
                if (!proposedSettings && this._matchesParentIDInList(element.id, this._asyncPostBackControlClientIDs)) {
                    proposedSettings = this._createPostBackSettings(true, null, elementUniqueID, originalElement);
                }
                else {
                    if (!proposedSettings && this._matchesParentIDInList(element.id, this._postBackControlClientIDs)) {
                        return this._createPostBackSettings(false);
                    }
                }
            }
            element = element.parentNode;
        }
        if (!proposedSettings) {
            return this._createPostBackSettings(false);
        }
        else {
            return proposedSettings;
        }
    }
    function Sys$WebForms$PageRequestManager$_getScrollPosition() {
        var d = document.documentElement;
        if (d && (this._validPosition(d.scrollLeft) || this._validPosition(d.scrollTop))) {
            return {
                x: d.scrollLeft,
                y: d.scrollTop
            };
        }
        else {
            d = document.body;
            if (d && (this._validPosition(d.scrollLeft) || this._validPosition(d.scrollTop))) {
                return {
                    x: d.scrollLeft,
                    y: d.scrollTop
                };
            }
            else {
                if (this._validPosition(window.pageXOffset) || this._validPosition(window.pageYOffset)) {
                    return {
                        x: window.pageXOffset,
                        y: window.pageYOffset
                    };
                }
                else {
                    return {
                        x: 0,
                        y: 0
                    };
                }
            }
        }
    }
    function Sys$WebForms$PageRequestManager$_initializeInternal(scriptManagerID, formElement, updatePanelIDs, asyncPostBackControlIDs, postBackControlIDs, asyncPostBackTimeout, masterPageUniqueID) {
        if (this._prmInitialized) {
            throw Error.invalidOperation(Sys.WebForms.Res.PRM_CannotRegisterTwice);
        }
        this._prmInitialized = true;
        this._masterPageUniqueID = masterPageUniqueID;
        this._scriptManagerID = scriptManagerID;
        this._form = Sys.UI.DomElement.resolveElement(formElement);
        this._onsubmit = this._form.onsubmit;
        this._form.onsubmit = null;
        this._onFormSubmitHandler = Function.createDelegate(this, this._onFormSubmit);
        this._onFormElementClickHandler = Function.createDelegate(this, this._onFormElementClick);
        this._onWindowUnloadHandler = Function.createDelegate(this, this._onWindowUnload);
        Sys.UI.DomEvent.addHandler(this._form, 'submit', this._onFormSubmitHandler);
        Sys.UI.DomEvent.addHandler(this._form, 'click', this._onFormElementClickHandler);
        Sys.UI.DomEvent.addHandler(window, 'unload', this._onWindowUnloadHandler);
        this._originalDoPostBack = window.__doPostBack;
        if (this._originalDoPostBack) {
            window.__doPostBack = Function.createDelegate(this, this._doPostBack);
        }
        this._originalDoPostBackWithOptions = window.WebForm_DoPostBackWithOptions;
        if (this._originalDoPostBackWithOptions) {
            window.WebForm_DoPostBackWithOptions = Function.createDelegate(this, this._doPostBackWithOptions);
        }
        this._originalFireDefaultButton = window.WebForm_FireDefaultButton;
        if (this._originalFireDefaultButton) {
            window.WebForm_FireDefaultButton = Function.createDelegate(this, this._fireDefaultButton);
        }
        this._originalDoCallback = window.WebForm_DoCallback;
        if (this._originalDoCallback) {
            window.WebForm_DoCallback = Function.createDelegate(this, this._doCallback);
        }
        this._pageLoadedHandler = Function.createDelegate(this, this._pageLoadedInitialLoad);
        Sys.UI.DomEvent.addHandler(window, 'load', this._pageLoadedHandler);
        if (updatePanelIDs) {
            this._updateControls(updatePanelIDs, asyncPostBackControlIDs, postBackControlIDs, asyncPostBackTimeout, true);
        }
    }
    function Sys$WebForms$PageRequestManager$_matchesParentIDInList(clientID, parentIDList) {
        for (var i = 0, l = parentIDList.length; i < l; i++) {
            if (clientID.startsWith(parentIDList[i] + "_")) {
                return true;
            }
        }
        return false;
    }
    function Sys$WebForms$PageRequestManager$_onFormElementActive(element, offsetX, offsetY) {
        if (element.disabled) {
            return;
        }
        this._activeElement = element;
        this._postBackSettings = this._getPostBackSettings(element, element.name);
        if (element.name) {
            var tagName = element.tagName.toUpperCase();
            if (tagName === 'INPUT') {
                var type = element.type;
                if (type === 'submit') {
                    this._additionalInput = encodeURIComponent(element.name) + '=' + encodeURIComponent(element.value);
                }
                else if (type === 'image') {
                    this._additionalInput = encodeURIComponent(element.name) + '.x=' + offsetX + '&' + encodeURIComponent(element.name) + '.y=' + offsetY;
                }
            }
            else if ((tagName === 'BUTTON') && (element.name.length !== 0) && (element.type === 'submit')) {
                this._additionalInput = encodeURIComponent(element.name) + '=' + encodeURIComponent(element.value);
            }
        }
    }
    function Sys$WebForms$PageRequestManager$_onFormElementClick(evt) {
        this._activeDefaultButtonClicked = (evt.target === this._activeDefaultButton);
        this._onFormElementActive(evt.target, evt.offsetX, evt.offsetY);
    }
    function Sys$WebForms$PageRequestManager$_onFormSubmit(evt) {
        var i, l, continueSubmit = true,
            isCrossPost = this._isCrossPost;
        this._isCrossPost = false;
        if (this._onsubmit) {
            continueSubmit = this._onsubmit();
        }
        if (continueSubmit) {
            for (i = 0, l = this._onSubmitStatements.length; i < l; i++) {
                if (!this._onSubmitStatements[i]()) {
                    continueSubmit = false;
                    break;
                }
            }
        }
        if (!continueSubmit) {
            if (evt) {
                evt.preventDefault();
            }
            return;
        }
        var form = this._form;
        if (isCrossPost) {
            return;
        }
        if (this._activeDefaultButton && !this._activeDefaultButtonClicked) {
            this._onFormElementActive(this._activeDefaultButton, 0, 0);
        }
        if (!this._postBackSettings || !this._postBackSettings.async) {
            return;
        }
        var formBody = new Sys.StringBuilder(),
            formElements = form.elements,
            count = formElements.length,
            panelID = this._createPanelID(null, this._postBackSettings);
        formBody.append(panelID);
        for (i = 0; i < count; i++) {
            var element = formElements[i];
            var name = element.name;
            if (typeof(name) === "undefined" || (name === null) || (name.length === 0) || (name === this._scriptManagerID)) {
                continue;
            }
            var tagName = element.tagName.toUpperCase();
            if (tagName === 'INPUT') {
                var type = element.type;
                if (this._textTypes.test(type)
                    || ((type === 'checkbox' || type === 'radio') && element.checked)) {
                    formBody.append(encodeURIComponent(name));
                    formBody.append('=');
                    formBody.append(encodeURIComponent(element.value));
                    formBody.append('&');
                }
            }
            else if (tagName === 'SELECT') {
                var optionCount = element.options.length;
                for (var j = 0; j < optionCount; j++) {
                    var option = element.options[j];
                    if (option.selected) {
                        formBody.append(encodeURIComponent(name));
                        formBody.append('=');
                        formBody.append(encodeURIComponent(option.value));
                        formBody.append('&');
                    }
                }
            }
            else if (tagName === 'TEXTAREA') {
                formBody.append(encodeURIComponent(name));
                formBody.append('=');
                formBody.append(encodeURIComponent(element.value));
                formBody.append('&');
            }
        }
        formBody.append("__ASYNCPOST=true&");
        if (this._additionalInput) {
            formBody.append(this._additionalInput);
            this._additionalInput = null;
        }
        
        var request = new Sys.Net.WebRequest();
        var action = form.action;
        if (Sys.Browser.agent === Sys.Browser.InternetExplorer) {
            var fragmentIndex = action.indexOf('#');
            if (fragmentIndex !== -1) {
                action = action.substr(0, fragmentIndex);
            }
            var domain = "", query = "", queryIndex = action.indexOf('?');
            if (queryIndex !== -1) {
                query = action.substr(queryIndex);
                action = action.substr(0, queryIndex);
            }
            if (/^https?\:\/\/.*$/gi.test(action)) {
                var domainPartIndex = action.indexOf("//") + 2,
                    slashAfterDomain = action.indexOf("/", domainPartIndex);
                if (slashAfterDomain === -1) {
                    domain = action;
                    action = "";
                }
                else {
                    domain = action.substr(0, slashAfterDomain);
                    action = action.substr(slashAfterDomain);
                }
            }
            action = domain + encodeURI(decodeURI(action)) + query;
        }
        request.set_url(action);
        request.get_headers()['X-MicrosoftAjax'] = 'Delta=true';
        request.get_headers()['Cache-Control'] = 'no-cache';
        request.set_timeout(this._asyncPostBackTimeout);
        request.add_completed(Function.createDelegate(this, this._onFormSubmitCompleted));
        request.set_body(formBody.toString());
        var panelsToUpdate, eventArgs, handler = this._get_eventHandlerList().getHandler("initializeRequest");
        if (handler) {
            panelsToUpdate = this._postBackSettings.panelsToUpdate;
            eventArgs = new Sys.WebForms.InitializeRequestEventArgs(request, this._postBackSettings.sourceElement, panelsToUpdate);
            handler(this, eventArgs);
            continueSubmit = !eventArgs.get_cancel();
        }
        if (!continueSubmit) {
            if (evt) {
                evt.preventDefault();
            }
            return;
        }
        
        if (eventArgs && eventArgs._updated) {
            panelsToUpdate = eventArgs.get_updatePanelsToUpdate();
            request.set_body(request.get_body().replace(panelID, this._createPanelID(panelsToUpdate, this._postBackSettings)));
        }
        this._scrollPosition = this._getScrollPosition();
        this.abortPostBack();
        handler = this._get_eventHandlerList().getHandler("beginRequest");
        if (handler) {
            eventArgs = new Sys.WebForms.BeginRequestEventArgs(request, this._postBackSettings.sourceElement,
                panelsToUpdate || this._postBackSettings.panelsToUpdate);
            handler(this, eventArgs);
        }
        
        if (this._originalDoCallback) {
            this._cancelPendingCallbacks();
        }
        this._request = request;
        this._processingRequest = false;
        request.invoke();
        if (evt) {
            evt.preventDefault();
        }
    }
    function Sys$WebForms$PageRequestManager$_onFormSubmitCompleted(sender, eventArgs) {
        this._processingRequest = true;
        if (sender.get_timedOut()) {
            this._endPostBack(this._createPageRequestManagerTimeoutError(), sender, null);
            return;
        }
        if (sender.get_aborted()) {
            this._endPostBack(null, sender, null);
            return;
        }
        if (!this._request || (sender.get_webRequest() !== this._request)) {
            return;
        }
        if (sender.get_statusCode() !== 200) {
            this._endPostBack(this._createPageRequestManagerServerError(sender.get_statusCode()), sender, null);
            return;
        }
        var data = this._parseDelta(sender);
        if (!data) return;
        
        var i, l;
        if (data.asyncPostBackControlIDsNode && data.postBackControlIDsNode &&
            data.updatePanelIDsNode && data.panelsToRefreshNode && data.childUpdatePanelIDsNode) {
            
            var oldUpdatePanelIDs = this._updatePanelIDs,
                oldUpdatePanelClientIDs = this._updatePanelClientIDs;
            var childUpdatePanelIDsString = data.childUpdatePanelIDsNode.content;
            var childUpdatePanelIDs = childUpdatePanelIDsString.length ? childUpdatePanelIDsString.split(',') : [];
            var asyncPostBackControlIDsArray = this._splitNodeIntoArray(data.asyncPostBackControlIDsNode);
            var postBackControlIDsArray = this._splitNodeIntoArray(data.postBackControlIDsNode);
            var updatePanelIDsArray = this._splitNodeIntoArray(data.updatePanelIDsNode);
            var panelsToRefreshIDs = this._splitNodeIntoArray(data.panelsToRefreshNode);
            var v4 = data.version4;
            for (i = 0, l = panelsToRefreshIDs.length; i < l; i+= (v4 ? 2 : 1)) {
                var panelClientID = (v4 ? panelsToRefreshIDs[i+1] : "") || this._uniqueIDToClientID(panelsToRefreshIDs[i]);
                if (!document.getElementById(panelClientID)) {
                    this._endPostBack(Error.invalidOperation(String.format(Sys.WebForms.Res.PRM_MissingPanel, panelClientID)), sender, data);
                    return;
                }
            }
            
            var updatePanelData = this._processUpdatePanelArrays(
                updatePanelIDsArray,
                asyncPostBackControlIDsArray,
                postBackControlIDsArray, v4);
            updatePanelData.oldUpdatePanelIDs = oldUpdatePanelIDs;
            updatePanelData.oldUpdatePanelClientIDs = oldUpdatePanelClientIDs;
            updatePanelData.childUpdatePanelIDs = childUpdatePanelIDs;
            updatePanelData.panelsToRefreshIDs = panelsToRefreshIDs;
            data.updatePanelData = updatePanelData;
        }
        data.dataItems = {};
        var node;
        for (i = 0, l = data.dataItemNodes.length; i < l; i++) {
            node = data.dataItemNodes[i];
            data.dataItems[node.id] = node.content;
        }
        for (i = 0, l = data.dataItemJsonNodes.length; i < l; i++) {
            node = data.dataItemJsonNodes[i];
            data.dataItems[node.id] = Sys.Serialization.JavaScriptSerializer.deserialize(node.content);
        }
        var handler = this._get_eventHandlerList().getHandler("pageLoading");
        if (handler) {
            handler(this, this._getPageLoadingEventArgs(data));
        }
        
        Sys._ScriptLoader.readLoadedScripts();
        Sys.Application.beginCreateComponents();
        var scriptLoader = Sys._ScriptLoader.getInstance();
        this._queueScripts(scriptLoader, data.scriptBlockNodes, true, false);
        
        this._processingRequest = true;
        scriptLoader.loadScripts(0,
            Function.createDelegate(this, Function.createCallback(this._scriptIncludesLoadComplete, data)),
            Function.createDelegate(this, Function.createCallback(this._scriptIncludesLoadFailed, data)),
            null);        
    }
    function Sys$WebForms$PageRequestManager$_onWindowUnload(evt) {
        this.dispose();
    }
    function Sys$WebForms$PageRequestManager$_pageLoaded(initialLoad, data) {
        var handler = this._get_eventHandlerList().getHandler("pageLoaded");
        if (handler) {
            handler(this, this._getPageLoadedEventArgs(initialLoad, data));
        }
        if (!initialLoad) {
            Sys.Application.raiseLoad();
        }
    }
    function Sys$WebForms$PageRequestManager$_pageLoadedInitialLoad(evt) {
        this._pageLoaded(true, null);
    }
    function Sys$WebForms$PageRequestManager$_parseDelta(executor) {
        var reply = executor.get_responseData();
        var delimiterIndex, len, type, id, content;
        var replyIndex = 0;
        var parserErrorDetails = null;
        var delta = [];
        while (replyIndex < reply.length) {
            delimiterIndex = reply.indexOf('|', replyIndex);
            if (delimiterIndex === -1) {
                parserErrorDetails = this._findText(reply, replyIndex);
                break;
            }
            len = parseInt(reply.substring(replyIndex, delimiterIndex), 10);
            if ((len % 1) !== 0) {
                parserErrorDetails = this._findText(reply, replyIndex);
                break;
            }
            replyIndex = delimiterIndex + 1;
            delimiterIndex = reply.indexOf('|', replyIndex);
            if (delimiterIndex === -1) {
                parserErrorDetails = this._findText(reply, replyIndex);
                break;
            }
            type = reply.substring(replyIndex, delimiterIndex);
            replyIndex = delimiterIndex + 1;
            delimiterIndex = reply.indexOf('|', replyIndex);
            if (delimiterIndex === -1) {
                parserErrorDetails = this._findText(reply, replyIndex);
                break;
            }
            id = reply.substring(replyIndex, delimiterIndex);
            replyIndex = delimiterIndex + 1;
            if ((replyIndex + len) >= reply.length) {
                parserErrorDetails = this._findText(reply, reply.length);
                break;
            }
            content = reply.substr(replyIndex, len);
            replyIndex += len;
            if (reply.charAt(replyIndex) !== '|') {
                parserErrorDetails = this._findText(reply, replyIndex);
                break;
            }
            replyIndex++;
            Array.add(delta, {type: type, id: id, content: content});
        }
        if (parserErrorDetails) {
            this._endPostBack(this._createPageRequestManagerParserError(String.format(Sys.WebForms.Res.PRM_ParserErrorDetails, parserErrorDetails)), executor, null);
            return null;
        }
        var updatePanelNodes = [];
        var hiddenFieldNodes = [];
        var arrayDeclarationNodes = [];
        var scriptBlockNodes = [];
        var scriptStartupNodes = [];
        var expandoNodes = [];
        var onSubmitNodes = [];
        var dataItemNodes = [];
        var dataItemJsonNodes = [];
        var scriptDisposeNodes = [];
        var asyncPostBackControlIDsNode, postBackControlIDsNode,
            updatePanelIDsNode, asyncPostBackTimeoutNode,
            childUpdatePanelIDsNode, panelsToRefreshNode, formActionNode,
            versionNode;
        for (var i = 0, l = delta.length; i < l; i++) {
            var deltaNode = delta[i];
            switch (deltaNode.type) {
                case "#":
                    versionNode = deltaNode;
                    break;
                case "updatePanel":
                    Array.add(updatePanelNodes, deltaNode);
                    break;
                case "hiddenField":
                    Array.add(hiddenFieldNodes, deltaNode);
                    break;
                case "arrayDeclaration":
                    Array.add(arrayDeclarationNodes, deltaNode);
                    break;
                case "scriptBlock":
                    Array.add(scriptBlockNodes, deltaNode);
                    break;
                case "fallbackScript":
                    scriptBlockNodes[scriptBlockNodes.length - 1].fallback = deltaNode.id;
                case "scriptStartupBlock":
                    Array.add(scriptStartupNodes, deltaNode);
                    break;
                case "expando":
                    Array.add(expandoNodes, deltaNode);
                    break;
                case "onSubmit":
                    Array.add(onSubmitNodes, deltaNode);
                    break;
                case "asyncPostBackControlIDs":
                    asyncPostBackControlIDsNode = deltaNode;
                    break;
                case "postBackControlIDs":
                    postBackControlIDsNode = deltaNode;
                    break;
                case "updatePanelIDs":
                    updatePanelIDsNode = deltaNode;
                    break;
                case "asyncPostBackTimeout":
                    asyncPostBackTimeoutNode = deltaNode;
                    break;
                case "childUpdatePanelIDs":
                    childUpdatePanelIDsNode = deltaNode;
                    break;
                case "panelsToRefreshIDs":
                    panelsToRefreshNode = deltaNode;
                    break;
                case "formAction":
                    formActionNode = deltaNode;
                    break;
                case "dataItem":
                    Array.add(dataItemNodes, deltaNode);
                    break;
                case "dataItemJson":
                    Array.add(dataItemJsonNodes, deltaNode);
                    break;
                case "scriptDispose":
                    Array.add(scriptDisposeNodes, deltaNode);
                    break;
                case "pageRedirect":
                    if (versionNode && parseFloat(versionNode.content) >= 4) {
                        deltaNode.content = unescape(deltaNode.content);
                    }
                    if (Sys.Browser.agent === Sys.Browser.InternetExplorer) {
                        var anchor = document.createElement("a");
                        anchor.style.display = 'none';
                        anchor.attachEvent("onclick", cancelBubble);
                        anchor.href = deltaNode.content;
                        this._form.parentNode.insertBefore(anchor, this._form);
                        anchor.click();
                        anchor.detachEvent("onclick", cancelBubble);
                        this._form.parentNode.removeChild(anchor);
                        
                        function cancelBubble(e) {
                            e.cancelBubble = true;
                        }
                    }
                    else {
                        window.location.href = deltaNode.content;
                    }
                    return null;
                case "error":
                    this._endPostBack(this._createPageRequestManagerServerError(Number.parseInvariant(deltaNode.id), deltaNode.content), executor, null);
                    return null;
                case "pageTitle":
                    document.title = deltaNode.content;
                    break;
                case "focus":
                    this._controlIDToFocus = deltaNode.content;
                    break;
                default:
                    this._endPostBack(this._createPageRequestManagerParserError(String.format(Sys.WebForms.Res.PRM_UnknownToken, deltaNode.type)), executor, null);
                    return null;
            } 
        } 
        return {
            version4: versionNode ? (parseFloat(versionNode.content) >= 4) : false,
            executor: executor,
            updatePanelNodes: updatePanelNodes,
            hiddenFieldNodes: hiddenFieldNodes,
            arrayDeclarationNodes: arrayDeclarationNodes,
            scriptBlockNodes: scriptBlockNodes,
            scriptStartupNodes: scriptStartupNodes,
            expandoNodes: expandoNodes,
            onSubmitNodes: onSubmitNodes,
            dataItemNodes: dataItemNodes,
            dataItemJsonNodes: dataItemJsonNodes,
            scriptDisposeNodes: scriptDisposeNodes,
            asyncPostBackControlIDsNode: asyncPostBackControlIDsNode,
            postBackControlIDsNode: postBackControlIDsNode,
            updatePanelIDsNode: updatePanelIDsNode,
            asyncPostBackTimeoutNode: asyncPostBackTimeoutNode,
            childUpdatePanelIDsNode: childUpdatePanelIDsNode,
            panelsToRefreshNode: panelsToRefreshNode,
            formActionNode: formActionNode };
    }
    function Sys$WebForms$PageRequestManager$_processUpdatePanelArrays(updatePanelIDs, asyncPostBackControlIDs, postBackControlIDs, version4) {
        var newUpdatePanelIDs, newUpdatePanelClientIDs, newUpdatePanelHasChildrenAsTriggers;
        
        if (updatePanelIDs) {
            var l = updatePanelIDs.length,
                m = version4 ? 2 : 1;
            newUpdatePanelIDs = new Array(l/m);
            newUpdatePanelClientIDs = new Array(l/m);
            newUpdatePanelHasChildrenAsTriggers = new Array(l/m);
            
            for (var i = 0, j = 0; i < l; i += m, j++) {
                var ct,
                    uniqueID = updatePanelIDs[i],
                    clientID = version4 ? updatePanelIDs[i+1] : "";
                ct = (uniqueID.charAt(0) === 't');
                uniqueID = uniqueID.substr(1);
                if (!clientID) {
                    clientID = this._uniqueIDToClientID(uniqueID);
                }
                newUpdatePanelHasChildrenAsTriggers[j] = ct;
                newUpdatePanelIDs[j] = uniqueID;
                newUpdatePanelClientIDs[j] = clientID;
            }
        }
        else {
            newUpdatePanelIDs = [];
            newUpdatePanelClientIDs = [];
            newUpdatePanelHasChildrenAsTriggers = [];
        }
        var newAsyncPostBackControlIDs = [];
        var newAsyncPostBackControlClientIDs = [];
        this._convertToClientIDs(asyncPostBackControlIDs, newAsyncPostBackControlIDs, newAsyncPostBackControlClientIDs, version4);
        var newPostBackControlIDs = [];
        var newPostBackControlClientIDs = [];
        this._convertToClientIDs(postBackControlIDs, newPostBackControlIDs, newPostBackControlClientIDs, version4);
        
        return {
            updatePanelIDs: newUpdatePanelIDs,
            updatePanelClientIDs: newUpdatePanelClientIDs,
            updatePanelHasChildrenAsTriggers: newUpdatePanelHasChildrenAsTriggers,
            asyncPostBackControlIDs: newAsyncPostBackControlIDs,
            asyncPostBackControlClientIDs: newAsyncPostBackControlClientIDs,
            postBackControlIDs: newPostBackControlIDs,
            postBackControlClientIDs: newPostBackControlClientIDs
        };
    }
    function Sys$WebForms$PageRequestManager$_queueScripts(scriptLoader, scriptBlockNodes, queueIncludes, queueBlocks) {
        
        for (var i = 0, l = scriptBlockNodes.length; i < l; i++) {
            var scriptBlockType = scriptBlockNodes[i].id;
            switch (scriptBlockType) {
                case "ScriptContentNoTags":
                    if (!queueBlocks) {
                        continue;
                    }
                    scriptLoader.queueScriptBlock(scriptBlockNodes[i].content);
                    break;
                case "ScriptContentWithTags":
                    var scriptTagAttributes;
                    eval("scriptTagAttributes = " + scriptBlockNodes[i].content);
                    if (scriptTagAttributes.src) {
                        if (!queueIncludes || Sys._ScriptLoader.isScriptLoaded(scriptTagAttributes.src)) {
                            continue;
                        }
                    }
                    else if (!queueBlocks) {
                        continue;
                    }
                    scriptLoader.queueCustomScriptTag(scriptTagAttributes);
                    break;
                case "ScriptPath":
                    var script = scriptBlockNodes[i];
                    if (!queueIncludes || Sys._ScriptLoader.isScriptLoaded(script.content)) {
                        continue;
                    }
                    scriptLoader.queueScriptReference(script.content, script.fallback);
                    break;
            }
        }        
    }
    function Sys$WebForms$PageRequestManager$_registerDisposeScript(panelID, disposeScript) {
        if (!this._scriptDisposes[panelID]) {
            this._scriptDisposes[panelID] = [disposeScript];
        }
        else {
            Array.add(this._scriptDisposes[panelID], disposeScript);
        }
    }
    function Sys$WebForms$PageRequestManager$_scriptIncludesLoadComplete(scriptLoader, data) {
        
        
        if (data.executor.get_webRequest() !== this._request) {
            return;
        }
        
        this._commitControls(data.updatePanelData,
            data.asyncPostBackTimeoutNode ? data.asyncPostBackTimeoutNode.content : null);
        if (data.formActionNode) {
            this._form.action = data.formActionNode.content;
        }
        
        var i, l, node;
        for (i = 0, l = data.updatePanelNodes.length; i < l; i++) {
            node = data.updatePanelNodes[i];
            var updatePanelElement = document.getElementById(node.id);
            if (!updatePanelElement) {
                this._endPostBack(Error.invalidOperation(String.format(Sys.WebForms.Res.PRM_MissingPanel, node.id)), data.executor, data);
                return;
            }
            this._updatePanel(updatePanelElement, node.content);
        }
        for (i = 0, l = data.scriptDisposeNodes.length; i < l; i++) {
            node = data.scriptDisposeNodes[i];
            this._registerDisposeScript(node.id, node.content);
        }
        for (i = 0, l = this._transientFields.length; i < l; i++) {
            var field = document.getElementById(this._transientFields[i]);
            if (field) {
                var toRemove = field._isContained ? field.parentNode : field;
                toRemove.parentNode.removeChild(toRemove);
            }
        }
        for (i = 0, l = data.hiddenFieldNodes.length; i < l; i++) {
            node = data.hiddenFieldNodes[i];
            this._createHiddenField(node.id, node.content);
        }
        
        if (data.scriptsFailed) {
            throw Sys._ScriptLoader._errorScriptLoadFailed(data.scriptsFailed.src, data.scriptsFailed.multipleCallbacks);
        }
        
        this._queueScripts(scriptLoader, data.scriptBlockNodes, false, true);
        var arrayScript = '';
        for (i = 0, l = data.arrayDeclarationNodes.length; i < l; i++) {
            node = data.arrayDeclarationNodes[i];
            arrayScript += "Sys.WebForms.PageRequestManager._addArrayElement('" + node.id + "', " + node.content + ");\r\n";
        }
        var expandoScript = '';
        for (i = 0, l = data.expandoNodes.length; i < l; i++) {
            node = data.expandoNodes[i];
            expandoScript += node.id + " = " + node.content + "\r\n";
        }
        if (arrayScript.length) {
            scriptLoader.queueScriptBlock(arrayScript);
        }
        if (expandoScript.length) {
            scriptLoader.queueScriptBlock(expandoScript);
        }
        
        this._queueScripts(scriptLoader, data.scriptStartupNodes, true, true);
        var onSubmitStatementScript = '';
        for (i = 0, l = data.onSubmitNodes.length; i < l; i++) {
            if (i === 0) {
                onSubmitStatementScript = 'Array.add(Sys.WebForms.PageRequestManager.getInstance()._onSubmitStatements, function() {\r\n';
            }
            onSubmitStatementScript += data.onSubmitNodes[i].content + "\r\n";
        }
        if (onSubmitStatementScript.length) {
            onSubmitStatementScript += "\r\nreturn true;\r\n});\r\n";
            scriptLoader.queueScriptBlock(onSubmitStatementScript);
        }
        scriptLoader.loadScripts(0,
            Function.createDelegate(this, Function.createCallback(this._scriptsLoadComplete, data)), null, null);
    }
    function Sys$WebForms$PageRequestManager$_scriptIncludesLoadFailed(scriptLoader, scriptElement, multipleCallbacks, data) {
        data.scriptsFailed = { src: scriptElement.src, multipleCallbacks: multipleCallbacks };
        this._scriptIncludesLoadComplete(scriptLoader, data);
    }
    function Sys$WebForms$PageRequestManager$_scriptsLoadComplete(scriptLoader, data) {
        
        
        var response = data.executor;
        if (window.__theFormPostData) {
            window.__theFormPostData = "";
        }
        if (window.__theFormPostCollection) {
            window.__theFormPostCollection = [];
        }
        if (window.WebForm_InitCallback) {
            window.WebForm_InitCallback();
        }
        if (this._scrollPosition) {
            if (window.scrollTo) {
                window.scrollTo(this._scrollPosition.x, this._scrollPosition.y);
            }
            this._scrollPosition = null;
        }
        Sys.Application.endCreateComponents();
        this._pageLoaded(false, data);
        this._endPostBack(null, response, data);
        if (this._controlIDToFocus) {
            var focusTarget;
            var oldContentEditableSetting;
            if (Sys.Browser.agent === Sys.Browser.InternetExplorer) {
                var targetControl = $get(this._controlIDToFocus);
                focusTarget = targetControl;
                if (targetControl && (!WebForm_CanFocus(targetControl))) {
                    focusTarget = WebForm_FindFirstFocusableChild(targetControl);
                }
                if (focusTarget && (typeof(focusTarget.contentEditable) !== "undefined")) {
                    oldContentEditableSetting = focusTarget.contentEditable;
                    focusTarget.contentEditable = false;
                }
                else {
                    focusTarget = null;
                }
            }
            WebForm_AutoFocus(this._controlIDToFocus);
            if (focusTarget) {
                focusTarget.contentEditable = oldContentEditableSetting;
            }
            this._controlIDToFocus = null;
        }
    }
    function Sys$WebForms$PageRequestManager$_splitNodeIntoArray(node) {
        var str = node.content;
        var arr = str.length ? str.split(',') : [];
        return arr;
    }
    function Sys$WebForms$PageRequestManager$_uniqueIDToClientID(uniqueID) {
        return uniqueID.replace(/\$/g, '_');
    }
    function Sys$WebForms$PageRequestManager$_updateControls(updatePanelIDs, asyncPostBackControlIDs, postBackControlIDs, asyncPostBackTimeout, version4) {
        this._commitControls(
            this._processUpdatePanelArrays(updatePanelIDs, asyncPostBackControlIDs, postBackControlIDs, version4),
            asyncPostBackTimeout);
    }
    function Sys$WebForms$PageRequestManager$_updatePanel(updatePanelElement, rendering) {
        for (var updatePanelID in this._scriptDisposes) {
            if (this._elementContains(updatePanelElement, document.getElementById(updatePanelID))) {
                var disposeScripts = this._scriptDisposes[updatePanelID];
                for (var i = 0, l = disposeScripts.length; i < l; i++) {
                    eval(disposeScripts[i]);
                }
                delete this._scriptDisposes[updatePanelID];
            }
        }
        Sys.Application.disposeElement(updatePanelElement, true);
        updatePanelElement.innerHTML = rendering;
    }
    function Sys$WebForms$PageRequestManager$_validPosition(position) {
        return (typeof(position) !== "undefined") && (position !== null) && (position !== 0);
    }
Sys.WebForms.PageRequestManager.prototype = {
    _get_eventHandlerList: Sys$WebForms$PageRequestManager$_get_eventHandlerList,
    get_isInAsyncPostBack: Sys$WebForms$PageRequestManager$get_isInAsyncPostBack,
    add_beginRequest: Sys$WebForms$PageRequestManager$add_beginRequest,
    remove_beginRequest: Sys$WebForms$PageRequestManager$remove_beginRequest,
    add_endRequest: Sys$WebForms$PageRequestManager$add_endRequest,
    remove_endRequest: Sys$WebForms$PageRequestManager$remove_endRequest,
    add_initializeRequest: Sys$WebForms$PageRequestManager$add_initializeRequest,
    remove_initializeRequest: Sys$WebForms$PageRequestManager$remove_initializeRequest,
    add_pageLoaded: Sys$WebForms$PageRequestManager$add_pageLoaded,
    remove_pageLoaded: Sys$WebForms$PageRequestManager$remove_pageLoaded,
    add_pageLoading: Sys$WebForms$PageRequestManager$add_pageLoading,
    remove_pageLoading: Sys$WebForms$PageRequestManager$remove_pageLoading,
    abortPostBack: Sys$WebForms$PageRequestManager$abortPostBack,
    beginAsyncPostBack: Sys$WebForms$PageRequestManager$beginAsyncPostBack,
    _cancelPendingCallbacks: Sys$WebForms$PageRequestManager$_cancelPendingCallbacks,
    _commitControls: Sys$WebForms$PageRequestManager$_commitControls,
    _createHiddenField: Sys$WebForms$PageRequestManager$_createHiddenField,
    _createPageRequestManagerTimeoutError: Sys$WebForms$PageRequestManager$_createPageRequestManagerTimeoutError,
    _createPageRequestManagerServerError: Sys$WebForms$PageRequestManager$_createPageRequestManagerServerError,
    _createPageRequestManagerParserError: Sys$WebForms$PageRequestManager$_createPageRequestManagerParserError,
    _createPanelID: Sys$WebForms$PageRequestManager$_createPanelID,
    _createPostBackSettings: Sys$WebForms$PageRequestManager$_createPostBackSettings,
    _convertToClientIDs: Sys$WebForms$PageRequestManager$_convertToClientIDs,
    dispose: Sys$WebForms$PageRequestManager$dispose,
    _doCallback: Sys$WebForms$PageRequestManager$_doCallback,
    _doPostBack: Sys$WebForms$PageRequestManager$_doPostBack,
    _doPostBackWithOptions: Sys$WebForms$PageRequestManager$_doPostBackWithOptions,
    _elementContains: Sys$WebForms$PageRequestManager$_elementContains,
    _endPostBack: Sys$WebForms$PageRequestManager$_endPostBack,
    _ensureUniqueIds: Sys$WebForms$PageRequestManager$_ensureUniqueIds,
    _findNearestElement: Sys$WebForms$PageRequestManager$_findNearestElement,
    _findText: Sys$WebForms$PageRequestManager$_findText,
    _fireDefaultButton: Sys$WebForms$PageRequestManager$_fireDefaultButton,
    _getPageLoadedEventArgs: Sys$WebForms$PageRequestManager$_getPageLoadedEventArgs,
    _getPageLoadingEventArgs: Sys$WebForms$PageRequestManager$_getPageLoadingEventArgs,
    _getPostBackSettings: Sys$WebForms$PageRequestManager$_getPostBackSettings,
    _getScrollPosition: Sys$WebForms$PageRequestManager$_getScrollPosition,
    _initializeInternal: Sys$WebForms$PageRequestManager$_initializeInternal,
    _matchesParentIDInList: Sys$WebForms$PageRequestManager$_matchesParentIDInList,
    _onFormElementActive: Sys$WebForms$PageRequestManager$_onFormElementActive,
    _onFormElementClick: Sys$WebForms$PageRequestManager$_onFormElementClick,
    _onFormSubmit: Sys$WebForms$PageRequestManager$_onFormSubmit,
    _onFormSubmitCompleted: Sys$WebForms$PageRequestManager$_onFormSubmitCompleted,
    _onWindowUnload: Sys$WebForms$PageRequestManager$_onWindowUnload,
    _pageLoaded: Sys$WebForms$PageRequestManager$_pageLoaded,
    _pageLoadedInitialLoad: Sys$WebForms$PageRequestManager$_pageLoadedInitialLoad,
    _parseDelta: Sys$WebForms$PageRequestManager$_parseDelta,
    _processUpdatePanelArrays: Sys$WebForms$PageRequestManager$_processUpdatePanelArrays,
    _queueScripts: Sys$WebForms$PageRequestManager$_queueScripts,
    _registerDisposeScript: Sys$WebForms$PageRequestManager$_registerDisposeScript,
    _scriptIncludesLoadComplete: Sys$WebForms$PageRequestManager$_scriptIncludesLoadComplete,
    _scriptIncludesLoadFailed: Sys$WebForms$PageRequestManager$_scriptIncludesLoadFailed,
    _scriptsLoadComplete: Sys$WebForms$PageRequestManager$_scriptsLoadComplete,
    _splitNodeIntoArray: Sys$WebForms$PageRequestManager$_splitNodeIntoArray,
    _uniqueIDToClientID: Sys$WebForms$PageRequestManager$_uniqueIDToClientID,
    _updateControls: Sys$WebForms$PageRequestManager$_updateControls,
    _updatePanel: Sys$WebForms$PageRequestManager$_updatePanel,
    _validPosition: Sys$WebForms$PageRequestManager$_validPosition
}
Sys.WebForms.PageRequestManager.getInstance = function Sys$WebForms$PageRequestManager$getInstance() {
    /// <summary locid="M:J#Sys.WebForms.PageRequestManager.getInstance" />
    /// <returns type="Sys.WebForms.PageRequestManager"></returns>
    if (arguments.length !== 0) throw Error.parameterCount();
    var prm = Sys.WebForms.PageRequestManager._instance;
    if (!prm) {
        prm = Sys.WebForms.PageRequestManager._instance = new Sys.WebForms.PageRequestManager();
    }
    return prm;
}
Sys.WebForms.PageRequestManager._addArrayElement = function Sys$WebForms$PageRequestManager$_addArrayElement(arrayName) {
    if (!window[arrayName]) {
        window[arrayName] = new Array();
    }
    for (var i = 1, l = arguments.length; i < l; i++) {
        Array.add(window[arrayName], arguments[i]);
    }
}
Sys.WebForms.PageRequestManager._initialize = function Sys$WebForms$PageRequestManager$_initialize() {
    var prm = Sys.WebForms.PageRequestManager.getInstance();
    prm._initializeInternal.apply(prm, arguments);
}
Sys.WebForms.PageRequestManager.registerClass('Sys.WebForms.PageRequestManager');
 
Sys.UI._UpdateProgress = function Sys$UI$_UpdateProgress(element) {
    Sys.UI._UpdateProgress.initializeBase(this,[element]);
    this._displayAfter = 500;
    this._dynamicLayout = true;
    this._associatedUpdatePanelId = null;
    this._beginRequestHandlerDelegate = null;
    this._startDelegate = null;
    this._endRequestHandlerDelegate = null;
    this._pageRequestManager = null;
    this._timerCookie = null;
}
    function Sys$UI$_UpdateProgress$get_displayAfter() {
        /// <value type="Number" locid="P:J#Sys.UI._UpdateProgress.displayAfter"></value>
        if (arguments.length !== 0) throw Error.parameterCount();
        return this._displayAfter;
    }
    function Sys$UI$_UpdateProgress$set_displayAfter(value) {
        var e = Function._validateParams(arguments, [{name: "value", type: Number}]);
        if (e) throw e;
        this._displayAfter = value;
    }
    function Sys$UI$_UpdateProgress$get_dynamicLayout() {
        /// <value type="Boolean" locid="P:J#Sys.UI._UpdateProgress.dynamicLayout"></value>
        if (arguments.length !== 0) throw Error.parameterCount();
        return this._dynamicLayout;
    }
    function Sys$UI$_UpdateProgress$set_dynamicLayout(value) {
        var e = Function._validateParams(arguments, [{name: "value", type: Boolean}]);
        if (e) throw e;
        this._dynamicLayout = value;
    }
    function Sys$UI$_UpdateProgress$get_associatedUpdatePanelId() {
        /// <value type="String" mayBeNull="true" locid="P:J#Sys.UI._UpdateProgress.associatedUpdatePanelId"></value>
        if (arguments.length !== 0) throw Error.parameterCount();
        return this._associatedUpdatePanelId;
    }
    function Sys$UI$_UpdateProgress$set_associatedUpdatePanelId(value) {
        var e = Function._validateParams(arguments, [{name: "value", type: String, mayBeNull: true}]);
        if (e) throw e;
        this._associatedUpdatePanelId = value;
    }
    function Sys$UI$_UpdateProgress$get_role() {
        /// <value type="String" locid="P:J#Sys.UI._UpdateProgress.role"></value>
        if (arguments.length !== 0) throw Error.parameterCount();
        return "status";
    }
    function Sys$UI$_UpdateProgress$_clearTimeout() {
        if (this._timerCookie) {
            window.clearTimeout(this._timerCookie);
            this._timerCookie = null;
        }
    }
    function Sys$UI$_UpdateProgress$_getUniqueID(clientID) {
        var i = Array.indexOf(this._pageRequestManager._updatePanelClientIDs, clientID);
        return i === -1 ? null : this._pageRequestManager._updatePanelIDs[i];
    }
    function Sys$UI$_UpdateProgress$_handleBeginRequest(sender, arg) {
        var curElem = arg.get_postBackElement(),
            showProgress = true,
            upID = this._associatedUpdatePanelId;
        if (this._associatedUpdatePanelId) {
            var updating = arg.get_updatePanelsToUpdate();
            if (updating && updating.length) {
                showProgress = (Array.contains(updating, upID) || Array.contains(updating, this._getUniqueID(upID)))
            }
            else {
                showProgress = false;
            }
        }
        while (!showProgress && curElem) {
            if (curElem.id && this._associatedUpdatePanelId === curElem.id) {
                showProgress = true; 
            }
            curElem = curElem.parentNode; 
        } 
        if (showProgress) {
            this._timerCookie = window.setTimeout(this._startDelegate, this._displayAfter);
        }
    }
    function Sys$UI$_UpdateProgress$_startRequest() {
        if (this._pageRequestManager.get_isInAsyncPostBack()) {
            var element = this.get_element();
            if (this._dynamicLayout) {
                element.style.display = 'block';
            }
            else {
                element.style.visibility = 'visible';
            }
            if (this.get_role() === "status") {
                element.setAttribute("aria-hidden", "false");
            }
        }
        this._timerCookie = null;
    }
    function Sys$UI$_UpdateProgress$_handleEndRequest(sender, arg) {
        var element = this.get_element();
        if (this._dynamicLayout) {
            element.style.display = 'none';
        }
        else {
            element.style.visibility = 'hidden';
        }
        if (this.get_role() === "status") {
            element.setAttribute("aria-hidden", "true");
        }
        this._clearTimeout();
    }
    function Sys$UI$_UpdateProgress$dispose() {
        if (this._beginRequestHandlerDelegate !== null) {
            this._pageRequestManager.remove_beginRequest(this._beginRequestHandlerDelegate);
            this._pageRequestManager.remove_endRequest(this._endRequestHandlerDelegate);
            this._beginRequestHandlerDelegate = null;
            this._endRequestHandlerDelegate = null;
        }
        this._clearTimeout();
        Sys.UI._UpdateProgress.callBaseMethod(this,"dispose");
    }
    function Sys$UI$_UpdateProgress$initialize() {
        Sys.UI._UpdateProgress.callBaseMethod(this, 'initialize');
        if (this.get_role() === "status") {
            this.get_element().setAttribute("aria-hidden", "true");
        }
    	this._beginRequestHandlerDelegate = Function.createDelegate(this, this._handleBeginRequest);
    	this._endRequestHandlerDelegate = Function.createDelegate(this, this._handleEndRequest);
    	this._startDelegate = Function.createDelegate(this, this._startRequest);
    	if (Sys.WebForms && Sys.WebForms.PageRequestManager) {
           this._pageRequestManager = Sys.WebForms.PageRequestManager.getInstance();
    	}
    	if (this._pageRequestManager !== null ) {
    	    this._pageRequestManager.add_beginRequest(this._beginRequestHandlerDelegate);
    	    this._pageRequestManager.add_endRequest(this._endRequestHandlerDelegate);
    	}
    }
Sys.UI._UpdateProgress.prototype = {
    get_displayAfter: Sys$UI$_UpdateProgress$get_displayAfter,
    set_displayAfter: Sys$UI$_UpdateProgress$set_displayAfter,
    get_dynamicLayout: Sys$UI$_UpdateProgress$get_dynamicLayout,
    set_dynamicLayout: Sys$UI$_UpdateProgress$set_dynamicLayout,
    get_associatedUpdatePanelId: Sys$UI$_UpdateProgress$get_associatedUpdatePanelId,
    set_associatedUpdatePanelId: Sys$UI$_UpdateProgress$set_associatedUpdatePanelId,
    get_role: Sys$UI$_UpdateProgress$get_role,
    _clearTimeout: Sys$UI$_UpdateProgress$_clearTimeout,
    _getUniqueID: Sys$UI$_UpdateProgress$_getUniqueID,
    _handleBeginRequest: Sys$UI$_UpdateProgress$_handleBeginRequest,
    _startRequest: Sys$UI$_UpdateProgress$_startRequest,
    _handleEndRequest: Sys$UI$_UpdateProgress$_handleEndRequest,
    dispose: Sys$UI$_UpdateProgress$dispose,
    initialize: Sys$UI$_UpdateProgress$initialize
}
Sys.UI._UpdateProgress.registerClass('Sys.UI._UpdateProgress', Sys.UI.Control);


Type.registerNamespace('Sys.WebForms');
Sys.WebForms.Res={
"PRM_UnknownToken":"Unknown token: \u0027{0}\u0027.",
"PRM_MissingPanel":"Could not find UpdatePanel with ID \u0027{0}\u0027. If it is being updated dynamically then it must be inside another UpdatePanel.",
"PRM_ServerError":"An unknown error occurred while processing the request on the server. The status code returned from the server was: {0}",
"PRM_ParserError":"The message received from the server could not be parsed.",
"PRM_TimeoutError":"The server request timed out.",
"PRM_ParserErrorDetails":"Error parsing near \u0027{0}\u0027.",
"PRM_CannotRegisterTwice":"The PageRequestManager cannot be initialized more than once."
};

/*! jQuery v1.8.2 jquery.com | jquery.org/license */
(function (a, b) { function G(a) { var b = F[a] = {}; return p.each(a.split(s), function (a, c) { b[c] = !0 }), b } function J(a, c, d) { if (d === b && a.nodeType === 1) { var e = "data-" + c.replace(I, "-$1").toLowerCase(); d = a.getAttribute(e); if (typeof d == "string") { try { d = d === "true" ? !0 : d === "false" ? !1 : d === "null" ? null : +d + "" === d ? +d : H.test(d) ? p.parseJSON(d) : d } catch (f) { } p.data(a, c, d) } else d = b } return d } function K(a) { var b; for (b in a) { if (b === "data" && p.isEmptyObject(a[b])) continue; if (b !== "toJSON") return !1 } return !0 } function ba() { return !1 } function bb() { return !0 } function bh(a) { return !a || !a.parentNode || a.parentNode.nodeType === 11 } function bi(a, b) { do a = a[b]; while (a && a.nodeType !== 1); return a } function bj(a, b, c) { b = b || 0; if (p.isFunction(b)) return p.grep(a, function (a, d) { var e = !!b.call(a, d, a); return e === c }); if (b.nodeType) return p.grep(a, function (a, d) { return a === b === c }); if (typeof b == "string") { var d = p.grep(a, function (a) { return a.nodeType === 1 }); if (be.test(b)) return p.filter(b, d, !c); b = p.filter(b, d) } return p.grep(a, function (a, d) { return p.inArray(a, b) >= 0 === c }) } function bk(a) { var b = bl.split("|"), c = a.createDocumentFragment(); if (c.createElement) while (b.length) c.createElement(b.pop()); return c } function bC(a, b) { return a.getElementsByTagName(b)[0] || a.appendChild(a.ownerDocument.createElement(b)) } function bD(a, b) { if (b.nodeType !== 1 || !p.hasData(a)) return; var c, d, e, f = p._data(a), g = p._data(b, f), h = f.events; if (h) { delete g.handle, g.events = {}; for (c in h) for (d = 0, e = h[c].length; d < e; d++) p.event.add(b, c, h[c][d]) } g.data && (g.data = p.extend({}, g.data)) } function bE(a, b) { var c; if (b.nodeType !== 1) return; b.clearAttributes && b.clearAttributes(), b.mergeAttributes && b.mergeAttributes(a), c = b.nodeName.toLowerCase(), c === "object" ? (b.parentNode && (b.outerHTML = a.outerHTML), p.support.html5Clone && a.innerHTML && !p.trim(b.innerHTML) && (b.innerHTML = a.innerHTML)) : c === "input" && bv.test(a.type) ? (b.defaultChecked = b.checked = a.checked, b.value !== a.value && (b.value = a.value)) : c === "option" ? b.selected = a.defaultSelected : c === "input" || c === "textarea" ? b.defaultValue = a.defaultValue : c === "script" && b.text !== a.text && (b.text = a.text), b.removeAttribute(p.expando) } function bF(a) { return typeof a.getElementsByTagName != "undefined" ? a.getElementsByTagName("*") : typeof a.querySelectorAll != "undefined" ? a.querySelectorAll("*") : [] } function bG(a) { bv.test(a.type) && (a.defaultChecked = a.checked) } function bY(a, b) { if (b in a) return b; var c = b.charAt(0).toUpperCase() + b.slice(1), d = b, e = bW.length; while (e--) { b = bW[e] + c; if (b in a) return b } return d } function bZ(a, b) { return a = b || a, p.css(a, "display") === "none" || !p.contains(a.ownerDocument, a) } function b$(a, b) { var c, d, e = [], f = 0, g = a.length; for (; f < g; f++) { c = a[f]; if (!c.style) continue; e[f] = p._data(c, "olddisplay"), b ? (!e[f] && c.style.display === "none" && (c.style.display = ""), c.style.display === "" && bZ(c) && (e[f] = p._data(c, "olddisplay", cc(c.nodeName)))) : (d = bH(c, "display"), !e[f] && d !== "none" && p._data(c, "olddisplay", d)) } for (f = 0; f < g; f++) { c = a[f]; if (!c.style) continue; if (!b || c.style.display === "none" || c.style.display === "") c.style.display = b ? e[f] || "" : "none" } return a } function b_(a, b, c) { var d = bP.exec(b); return d ? Math.max(0, d[1] - (c || 0)) + (d[2] || "px") : b } function ca(a, b, c, d) { var e = c === (d ? "border" : "content") ? 4 : b === "width" ? 1 : 0, f = 0; for (; e < 4; e += 2) c === "margin" && (f += p.css(a, c + bV[e], !0)), d ? (c === "content" && (f -= parseFloat(bH(a, "padding" + bV[e])) || 0), c !== "margin" && (f -= parseFloat(bH(a, "border" + bV[e] + "Width")) || 0)) : (f += parseFloat(bH(a, "padding" + bV[e])) || 0, c !== "padding" && (f += parseFloat(bH(a, "border" + bV[e] + "Width")) || 0)); return f } function cb(a, b, c) { var d = b === "width" ? a.offsetWidth : a.offsetHeight, e = !0, f = p.support.boxSizing && p.css(a, "boxSizing") === "border-box"; if (d <= 0 || d == null) { d = bH(a, b); if (d < 0 || d == null) d = a.style[b]; if (bQ.test(d)) return d; e = f && (p.support.boxSizingReliable || d === a.style[b]), d = parseFloat(d) || 0 } return d + ca(a, b, c || (f ? "border" : "content"), e) + "px" } function cc(a) { if (bS[a]) return bS[a]; var b = p("<" + a + ">").appendTo(e.body), c = b.css("display"); b.remove(); if (c === "none" || c === "") { bI = e.body.appendChild(bI || p.extend(e.createElement("iframe"), { frameBorder: 0, width: 0, height: 0 })); if (!bJ || !bI.createElement) bJ = (bI.contentWindow || bI.contentDocument).document, bJ.write("<!doctype html><html><body>"), bJ.close(); b = bJ.body.appendChild(bJ.createElement(a)), c = bH(b, "display"), e.body.removeChild(bI) } return bS[a] = c, c } function ci(a, b, c, d) { var e; if (p.isArray(b)) p.each(b, function (b, e) { c || ce.test(a) ? d(a, e) : ci(a + "[" + (typeof e == "object" ? b : "") + "]", e, c, d) }); else if (!c && p.type(b) === "object") for (e in b) ci(a + "[" + e + "]", b[e], c, d); else d(a, b) } function cz(a) { return function (b, c) { typeof b != "string" && (c = b, b = "*"); var d, e, f, g = b.toLowerCase().split(s), h = 0, i = g.length; if (p.isFunction(c)) for (; h < i; h++) d = g[h], f = /^\+/.test(d), f && (d = d.substr(1) || "*"), e = a[d] = a[d] || [], e[f ? "unshift" : "push"](c) } } function cA(a, c, d, e, f, g) { f = f || c.dataTypes[0], g = g || {}, g[f] = !0; var h, i = a[f], j = 0, k = i ? i.length : 0, l = a === cv; for (; j < k && (l || !h); j++) h = i[j](c, d, e), typeof h == "string" && (!l || g[h] ? h = b : (c.dataTypes.unshift(h), h = cA(a, c, d, e, h, g))); return (l || !h) && !g["*"] && (h = cA(a, c, d, e, "*", g)), h } function cB(a, c) { var d, e, f = p.ajaxSettings.flatOptions || {}; for (d in c) c[d] !== b && ((f[d] ? a : e || (e = {}))[d] = c[d]); e && p.extend(!0, a, e) } function cC(a, c, d) { var e, f, g, h, i = a.contents, j = a.dataTypes, k = a.responseFields; for (f in k) f in d && (c[k[f]] = d[f]); while (j[0] === "*") j.shift(), e === b && (e = a.mimeType || c.getResponseHeader("content-type")); if (e) for (f in i) if (i[f] && i[f].test(e)) { j.unshift(f); break } if (j[0] in d) g = j[0]; else { for (f in d) { if (!j[0] || a.converters[f + " " + j[0]]) { g = f; break } h || (h = f) } g = g || h } if (g) return g !== j[0] && j.unshift(g), d[g] } function cD(a, b) { var c, d, e, f, g = a.dataTypes.slice(), h = g[0], i = {}, j = 0; a.dataFilter && (b = a.dataFilter(b, a.dataType)); if (g[1]) for (c in a.converters) i[c.toLowerCase()] = a.converters[c]; for (; e = g[++j]; ) if (e !== "*") { if (h !== "*" && h !== e) { c = i[h + " " + e] || i["* " + e]; if (!c) for (d in i) { f = d.split(" "); if (f[1] === e) { c = i[h + " " + f[0]] || i["* " + f[0]]; if (c) { c === !0 ? c = i[d] : i[d] !== !0 && (e = f[0], g.splice(j--, 0, e)); break } } } if (c !== !0) if (c && a["throws"]) b = c(b); else try { b = c(b) } catch (k) { return { state: "parsererror", error: c ? k : "No conversion from " + h + " to " + e} } } h = e } return { state: "success", data: b} } function cL() { try { return new a.XMLHttpRequest } catch (b) { } } function cM() { try { return new a.ActiveXObject("Microsoft.XMLHTTP") } catch (b) { } } function cU() { return setTimeout(function () { cN = b }, 0), cN = p.now() } function cV(a, b) { p.each(b, function (b, c) { var d = (cT[b] || []).concat(cT["*"]), e = 0, f = d.length; for (; e < f; e++) if (d[e].call(a, b, c)) return }) } function cW(a, b, c) { var d, e = 0, f = 0, g = cS.length, h = p.Deferred().always(function () { delete i.elem }), i = function () { var b = cN || cU(), c = Math.max(0, j.startTime + j.duration - b), d = 1 - (c / j.duration || 0), e = 0, f = j.tweens.length; for (; e < f; e++) j.tweens[e].run(d); return h.notifyWith(a, [j, d, c]), d < 1 && f ? c : (h.resolveWith(a, [j]), !1) }, j = h.promise({ elem: a, props: p.extend({}, b), opts: p.extend(!0, { specialEasing: {} }, c), originalProperties: b, originalOptions: c, startTime: cN || cU(), duration: c.duration, tweens: [], createTween: function (b, c, d) { var e = p.Tween(a, j.opts, b, c, j.opts.specialEasing[b] || j.opts.easing); return j.tweens.push(e), e }, stop: function (b) { var c = 0, d = b ? j.tweens.length : 0; for (; c < d; c++) j.tweens[c].run(1); return b ? h.resolveWith(a, [j, b]) : h.rejectWith(a, [j, b]), this } }), k = j.props; cX(k, j.opts.specialEasing); for (; e < g; e++) { d = cS[e].call(j, a, k, j.opts); if (d) return d } return cV(j, k), p.isFunction(j.opts.start) && j.opts.start.call(a, j), p.fx.timer(p.extend(i, { anim: j, queue: j.opts.queue, elem: a })), j.progress(j.opts.progress).done(j.opts.done, j.opts.complete).fail(j.opts.fail).always(j.opts.always) } function cX(a, b) { var c, d, e, f, g; for (c in a) { d = p.camelCase(c), e = b[d], f = a[c], p.isArray(f) && (e = f[1], f = a[c] = f[0]), c !== d && (a[d] = f, delete a[c]), g = p.cssHooks[d]; if (g && "expand" in g) { f = g.expand(f), delete a[d]; for (c in f) c in a || (a[c] = f[c], b[c] = e) } else b[d] = e } } function cY(a, b, c) { var d, e, f, g, h, i, j, k, l = this, m = a.style, n = {}, o = [], q = a.nodeType && bZ(a); c.queue || (j = p._queueHooks(a, "fx"), j.unqueued == null && (j.unqueued = 0, k = j.empty.fire, j.empty.fire = function () { j.unqueued || k() }), j.unqueued++, l.always(function () { l.always(function () { j.unqueued--, p.queue(a, "fx").length || j.empty.fire() }) })), a.nodeType === 1 && ("height" in b || "width" in b) && (c.overflow = [m.overflow, m.overflowX, m.overflowY], p.css(a, "display") === "inline" && p.css(a, "float") === "none" && (!p.support.inlineBlockNeedsLayout || cc(a.nodeName) === "inline" ? m.display = "inline-block" : m.zoom = 1)), c.overflow && (m.overflow = "hidden", p.support.shrinkWrapBlocks || l.done(function () { m.overflow = c.overflow[0], m.overflowX = c.overflow[1], m.overflowY = c.overflow[2] })); for (d in b) { f = b[d]; if (cP.exec(f)) { delete b[d]; if (f === (q ? "hide" : "show")) continue; o.push(d) } } g = o.length; if (g) { h = p._data(a, "fxshow") || p._data(a, "fxshow", {}), q ? p(a).show() : l.done(function () { p(a).hide() }), l.done(function () { var b; p.removeData(a, "fxshow", !0); for (b in n) p.style(a, b, n[b]) }); for (d = 0; d < g; d++) e = o[d], i = l.createTween(e, q ? h[e] : 0), n[e] = h[e] || p.style(a, e), e in h || (h[e] = i.start, q && (i.end = i.start, i.start = e === "width" || e === "height" ? 1 : 0)) } } function cZ(a, b, c, d, e) { return new cZ.prototype.init(a, b, c, d, e) } function c$(a, b) { var c, d = { height: a }, e = 0; b = b ? 1 : 0; for (; e < 4; e += 2 - b) c = bV[e], d["margin" + c] = d["padding" + c] = a; return b && (d.opacity = d.width = a), d } function da(a) { return p.isWindow(a) ? a : a.nodeType === 9 ? a.defaultView || a.parentWindow : !1 } var c, d, e = a.document, f = a.location, g = a.navigator, h = a.jQuery, i = a.$, j = Array.prototype.push, k = Array.prototype.slice, l = Array.prototype.indexOf, m = Object.prototype.toString, n = Object.prototype.hasOwnProperty, o = String.prototype.trim, p = function (a, b) { return new p.fn.init(a, b, c) }, q = /[\-+]?(?:\d*\.|)\d+(?:[eE][\-+]?\d+|)/.source, r = /\S/, s = /\s+/, t = /^[\s\uFEFF\xA0]+|[\s\uFEFF\xA0]+$/g, u = /^(?:[^#<]*(<[\w\W]+>)[^>]*$|#([\w\-]*)$)/, v = /^<(\w+)\s*\/?>(?:<\/\1>|)$/, w = /^[\],:{}\s]*$/, x = /(?:^|:|,)(?:\s*\[)+/g, y = /\\(?:["\\\/bfnrt]|u[\da-fA-F]{4})/g, z = /"[^"\\\r\n]*"|true|false|null|-?(?:\d\d*\.|)\d+(?:[eE][\-+]?\d+|)/g, A = /^-ms-/, B = /-([\da-z])/gi, C = function (a, b) { return (b + "").toUpperCase() }, D = function () { e.addEventListener ? (e.removeEventListener("DOMContentLoaded", D, !1), p.ready()) : e.readyState === "complete" && (e.detachEvent("onreadystatechange", D), p.ready()) }, E = {}; p.fn = p.prototype = { constructor: p, init: function (a, c, d) { var f, g, h, i; if (!a) return this; if (a.nodeType) return this.context = this[0] = a, this.length = 1, this; if (typeof a == "string") { a.charAt(0) === "<" && a.charAt(a.length - 1) === ">" && a.length >= 3 ? f = [null, a, null] : f = u.exec(a); if (f && (f[1] || !c)) { if (f[1]) return c = c instanceof p ? c[0] : c, i = c && c.nodeType ? c.ownerDocument || c : e, a = p.parseHTML(f[1], i, !0), v.test(f[1]) && p.isPlainObject(c) && this.attr.call(a, c, !0), p.merge(this, a); g = e.getElementById(f[2]); if (g && g.parentNode) { if (g.id !== f[2]) return d.find(a); this.length = 1, this[0] = g } return this.context = e, this.selector = a, this } return !c || c.jquery ? (c || d).find(a) : this.constructor(c).find(a) } return p.isFunction(a) ? d.ready(a) : (a.selector !== b && (this.selector = a.selector, this.context = a.context), p.makeArray(a, this)) }, selector: "", jquery: "1.8.2", length: 0, size: function () { return this.length }, toArray: function () { return k.call(this) }, get: function (a) { return a == null ? this.toArray() : a < 0 ? this[this.length + a] : this[a] }, pushStack: function (a, b, c) { var d = p.merge(this.constructor(), a); return d.prevObject = this, d.context = this.context, b === "find" ? d.selector = this.selector + (this.selector ? " " : "") + c : b && (d.selector = this.selector + "." + b + "(" + c + ")"), d }, each: function (a, b) { return p.each(this, a, b) }, ready: function (a) { return p.ready.promise().done(a), this }, eq: function (a) { return a = +a, a === -1 ? this.slice(a) : this.slice(a, a + 1) }, first: function () { return this.eq(0) }, last: function () { return this.eq(-1) }, slice: function () { return this.pushStack(k.apply(this, arguments), "slice", k.call(arguments).join(",")) }, map: function (a) { return this.pushStack(p.map(this, function (b, c) { return a.call(b, c, b) })) }, end: function () { return this.prevObject || this.constructor(null) }, push: j, sort: [].sort, splice: [].splice }, p.fn.init.prototype = p.fn, p.extend = p.fn.extend = function () { var a, c, d, e, f, g, h = arguments[0] || {}, i = 1, j = arguments.length, k = !1; typeof h == "boolean" && (k = h, h = arguments[1] || {}, i = 2), typeof h != "object" && !p.isFunction(h) && (h = {}), j === i && (h = this, --i); for (; i < j; i++) if ((a = arguments[i]) != null) for (c in a) { d = h[c], e = a[c]; if (h === e) continue; k && e && (p.isPlainObject(e) || (f = p.isArray(e))) ? (f ? (f = !1, g = d && p.isArray(d) ? d : []) : g = d && p.isPlainObject(d) ? d : {}, h[c] = p.extend(k, g, e)) : e !== b && (h[c] = e) } return h }, p.extend({ noConflict: function (b) { return a.$ === p && (a.$ = i), b && a.jQuery === p && (a.jQuery = h), p }, isReady: !1, readyWait: 1, holdReady: function (a) { a ? p.readyWait++ : p.ready(!0) }, ready: function (a) { if (a === !0 ? --p.readyWait : p.isReady) return; if (!e.body) return setTimeout(p.ready, 1); p.isReady = !0; if (a !== !0 && --p.readyWait > 0) return; d.resolveWith(e, [p]), p.fn.trigger && p(e).trigger("ready").off("ready") }, isFunction: function (a) { return p.type(a) === "function" }, isArray: Array.isArray || function (a) { return p.type(a) === "array" }, isWindow: function (a) { return a != null && a == a.window }, isNumeric: function (a) { return !isNaN(parseFloat(a)) && isFinite(a) }, type: function (a) { return a == null ? String(a) : E[m.call(a)] || "object" }, isPlainObject: function (a) { if (!a || p.type(a) !== "object" || a.nodeType || p.isWindow(a)) return !1; try { if (a.constructor && !n.call(a, "constructor") && !n.call(a.constructor.prototype, "isPrototypeOf")) return !1 } catch (c) { return !1 } var d; for (d in a); return d === b || n.call(a, d) }, isEmptyObject: function (a) { var b; for (b in a) return !1; return !0 }, error: function (a) { throw new Error(a) }, parseHTML: function (a, b, c) { var d; return !a || typeof a != "string" ? null : (typeof b == "boolean" && (c = b, b = 0), b = b || e, (d = v.exec(a)) ? [b.createElement(d[1])] : (d = p.buildFragment([a], b, c ? null : []), p.merge([], (d.cacheable ? p.clone(d.fragment) : d.fragment).childNodes))) }, parseJSON: function (b) { if (!b || typeof b != "string") return null; b = p.trim(b); if (a.JSON && a.JSON.parse) return a.JSON.parse(b); if (w.test(b.replace(y, "@").replace(z, "]").replace(x, ""))) return (new Function("return " + b))(); p.error("Invalid JSON: " + b) }, parseXML: function (c) { var d, e; if (!c || typeof c != "string") return null; try { a.DOMParser ? (e = new DOMParser, d = e.parseFromString(c, "text/xml")) : (d = new ActiveXObject("Microsoft.XMLDOM"), d.async = "false", d.loadXML(c)) } catch (f) { d = b } return (!d || !d.documentElement || d.getElementsByTagName("parsererror").length) && p.error("Invalid XML: " + c), d }, noop: function () { }, globalEval: function (b) { b && r.test(b) && (a.execScript || function (b) { a.eval.call(a, b) })(b) }, camelCase: function (a) { return a.replace(A, "ms-").replace(B, C) }, nodeName: function (a, b) { return a.nodeName && a.nodeName.toLowerCase() === b.toLowerCase() }, each: function (a, c, d) { var e, f = 0, g = a.length, h = g === b || p.isFunction(a); if (d) { if (h) { for (e in a) if (c.apply(a[e], d) === !1) break } else for (; f < g; ) if (c.apply(a[f++], d) === !1) break } else if (h) { for (e in a) if (c.call(a[e], e, a[e]) === !1) break } else for (; f < g; ) if (c.call(a[f], f, a[f++]) === !1) break; return a }, trim: o && !o.call("? ") ? function (a) { return a == null ? "" : o.call(a) } : function (a) { return a == null ? "" : (a + "").replace(t, "") }, makeArray: function (a, b) { var c, d = b || []; return a != null && (c = p.type(a), a.length == null || c === "string" || c === "function" || c === "regexp" || p.isWindow(a) ? j.call(d, a) : p.merge(d, a)), d }, inArray: function (a, b, c) { var d; if (b) { if (l) return l.call(b, a, c); d = b.length, c = c ? c < 0 ? Math.max(0, d + c) : c : 0; for (; c < d; c++) if (c in b && b[c] === a) return c } return -1 }, merge: function (a, c) { var d = c.length, e = a.length, f = 0; if (typeof d == "number") for (; f < d; f++) a[e++] = c[f]; else while (c[f] !== b) a[e++] = c[f++]; return a.length = e, a }, grep: function (a, b, c) { var d, e = [], f = 0, g = a.length; c = !!c; for (; f < g; f++) d = !!b(a[f], f), c !== d && e.push(a[f]); return e }, map: function (a, c, d) { var e, f, g = [], h = 0, i = a.length, j = a instanceof p || i !== b && typeof i == "number" && (i > 0 && a[0] && a[i - 1] || i === 0 || p.isArray(a)); if (j) for (; h < i; h++) e = c(a[h], h, d), e != null && (g[g.length] = e); else for (f in a) e = c(a[f], f, d), e != null && (g[g.length] = e); return g.concat.apply([], g) }, guid: 1, proxy: function (a, c) { var d, e, f; return typeof c == "string" && (d = a[c], c = a, a = d), p.isFunction(a) ? (e = k.call(arguments, 2), f = function () { return a.apply(c, e.concat(k.call(arguments))) }, f.guid = a.guid = a.guid || p.guid++, f) : b }, access: function (a, c, d, e, f, g, h) { var i, j = d == null, k = 0, l = a.length; if (d && typeof d == "object") { for (k in d) p.access(a, c, k, d[k], 1, g, e); f = 1 } else if (e !== b) { i = h === b && p.isFunction(e), j && (i ? (i = c, c = function (a, b, c) { return i.call(p(a), c) }) : (c.call(a, e), c = null)); if (c) for (; k < l; k++) c(a[k], d, i ? e.call(a[k], k, c(a[k], d)) : e, h); f = 1 } return f ? a : j ? c.call(a) : l ? c(a[0], d) : g }, now: function () { return (new Date).getTime() } }), p.ready.promise = function (b) { if (!d) { d = p.Deferred(); if (e.readyState === "complete") setTimeout(p.ready, 1); else if (e.addEventListener) e.addEventListener("DOMContentLoaded", D, !1), a.addEventListener("load", p.ready, !1); else { e.attachEvent("onreadystatechange", D), a.attachEvent("onload", p.ready); var c = !1; try { c = a.frameElement == null && e.documentElement } catch (f) { } c && c.doScroll && function g() { if (!p.isReady) { try { c.doScroll("left") } catch (a) { return setTimeout(g, 50) } p.ready() } } () } } return d.promise(b) }, p.each("Boolean Number String Function Array Date RegExp Object".split(" "), function (a, b) { E["[object " + b + "]"] = b.toLowerCase() }), c = p(e); var F = {}; p.Callbacks = function (a) { a = typeof a == "string" ? F[a] || G(a) : p.extend({}, a); var c, d, e, f, g, h, i = [], j = !a.once && [], k = function (b) { c = a.memory && b, d = !0, h = f || 0, f = 0, g = i.length, e = !0; for (; i && h < g; h++) if (i[h].apply(b[0], b[1]) === !1 && a.stopOnFalse) { c = !1; break } e = !1, i && (j ? j.length && k(j.shift()) : c ? i = [] : l.disable()) }, l = { add: function () { if (i) { var b = i.length; (function d(b) { p.each(b, function (b, c) { var e = p.type(c); e === "function" && (!a.unique || !l.has(c)) ? i.push(c) : c && c.length && e !== "string" && d(c) }) })(arguments), e ? g = i.length : c && (f = b, k(c)) } return this }, remove: function () { return i && p.each(arguments, function (a, b) { var c; while ((c = p.inArray(b, i, c)) > -1) i.splice(c, 1), e && (c <= g && g--, c <= h && h--) }), this }, has: function (a) { return p.inArray(a, i) > -1 }, empty: function () { return i = [], this }, disable: function () { return i = j = c = b, this }, disabled: function () { return !i }, lock: function () { return j = b, c || l.disable(), this }, locked: function () { return !j }, fireWith: function (a, b) { return b = b || [], b = [a, b.slice ? b.slice() : b], i && (!d || j) && (e ? j.push(b) : k(b)), this }, fire: function () { return l.fireWith(this, arguments), this }, fired: function () { return !!d } }; return l }, p.extend({ Deferred: function (a) { var b = [["resolve", "done", p.Callbacks("once memory"), "resolved"], ["reject", "fail", p.Callbacks("once memory"), "rejected"], ["notify", "progress", p.Callbacks("memory")]], c = "pending", d = { state: function () { return c }, always: function () { return e.done(arguments).fail(arguments), this }, then: function () { var a = arguments; return p.Deferred(function (c) { p.each(b, function (b, d) { var f = d[0], g = a[b]; e[d[1]](p.isFunction(g) ? function () { var a = g.apply(this, arguments); a && p.isFunction(a.promise) ? a.promise().done(c.resolve).fail(c.reject).progress(c.notify) : c[f + "With"](this === e ? c : this, [a]) } : c[f]) }), a = null }).promise() }, promise: function (a) { return a != null ? p.extend(a, d) : d } }, e = {}; return d.pipe = d.then, p.each(b, function (a, f) { var g = f[2], h = f[3]; d[f[1]] = g.add, h && g.add(function () { c = h }, b[a ^ 1][2].disable, b[2][2].lock), e[f[0]] = g.fire, e[f[0] + "With"] = g.fireWith }), d.promise(e), a && a.call(e, e), e }, when: function (a) { var b = 0, c = k.call(arguments), d = c.length, e = d !== 1 || a && p.isFunction(a.promise) ? d : 0, f = e === 1 ? a : p.Deferred(), g = function (a, b, c) { return function (d) { b[a] = this, c[a] = arguments.length > 1 ? k.call(arguments) : d, c === h ? f.notifyWith(b, c) : --e || f.resolveWith(b, c) } }, h, i, j; if (d > 1) { h = new Array(d), i = new Array(d), j = new Array(d); for (; b < d; b++) c[b] && p.isFunction(c[b].promise) ? c[b].promise().done(g(b, j, c)).fail(f.reject).progress(g(b, i, h)) : --e } return e || f.resolveWith(j, c), f.promise() } }), p.support = function () { var b, c, d, f, g, h, i, j, k, l, m, n = e.createElement("div"); n.setAttribute("className", "t"), n.innerHTML = "  <link/><table></table><a href='/a'>a</a><input type='checkbox'/>", c = n.getElementsByTagName("*"), d = n.getElementsByTagName("a")[0], d.style.cssText = "top:1px;float:left;opacity:.5"; if (!c || !c.length) return {}; f = e.createElement("select"), g = f.appendChild(e.createElement("option")), h = n.getElementsByTagName("input")[0], b = { leadingWhitespace: n.firstChild.nodeType === 3, tbody: !n.getElementsByTagName("tbody").length, htmlSerialize: !!n.getElementsByTagName("link").length, style: /top/.test(d.getAttribute("style")), hrefNormalized: d.getAttribute("href") === "/a", opacity: /^0.5/.test(d.style.opacity), cssFloat: !!d.style.cssFloat, checkOn: h.value === "on", optSelected: g.selected, getSetAttribute: n.className !== "t", enctype: !!e.createElement("form").enctype, html5Clone: e.createElement("nav").cloneNode(!0).outerHTML !== "<:nav></:nav>", boxModel: e.compatMode === "CSS1Compat", submitBubbles: !0, changeBubbles: !0, focusinBubbles: !1, deleteExpando: !0, noCloneEvent: !0, inlineBlockNeedsLayout: !1, shrinkWrapBlocks: !1, reliableMarginRight: !0, boxSizingReliable: !0, pixelPosition: !1 }, h.checked = !0, b.noCloneChecked = h.cloneNode(!0).checked, f.disabled = !0, b.optDisabled = !g.disabled; try { delete n.test } catch (o) { b.deleteExpando = !1 } !n.addEventListener && n.attachEvent && n.fireEvent && (n.attachEvent("onclick", m = function () { b.noCloneEvent = !1 }), n.cloneNode(!0).fireEvent("onclick"), n.detachEvent("onclick", m)), h = e.createElement("input"), h.value = "t", h.setAttribute("type", "radio"), b.radioValue = h.value === "t", h.setAttribute("checked", "checked"), h.setAttribute("name", "t"), n.appendChild(h), i = e.createDocumentFragment(), i.appendChild(n.lastChild), b.checkClone = i.cloneNode(!0).cloneNode(!0).lastChild.checked, b.appendChecked = h.checked, i.removeChild(h), i.appendChild(n); if (n.attachEvent) for (k in { submit: !0, change: !0, focusin: !0 }) j = "on" + k, l = j in n, l || (n.setAttribute(j, "return;"), l = typeof n[j] == "function"), b[k + "Bubbles"] = l; return p(function () { var c, d, f, g, h = "padding:0;margin:0;border:0;display:block;overflow:hidden;", i = e.getElementsByTagName("body")[0]; if (!i) return; c = e.createElement("div"), c.style.cssText = "visibility:hidden;border:0;width:0;height:0;position:static;top:0;margin-top:1px", i.insertBefore(c, i.firstChild), d = e.createElement("div"), c.appendChild(d), d.innerHTML = "<table><tr><td></td><td>t</td></tr></table>", f = d.getElementsByTagName("td"), f[0].style.cssText = "padding:0;margin:0;border:0;display:none", l = f[0].offsetHeight === 0, f[0].style.display = "", f[1].style.display = "none", b.reliableHiddenOffsets = l && f[0].offsetHeight === 0, d.innerHTML = "", d.style.cssText = "box-sizing:border-box;-moz-box-sizing:border-box;-webkit-box-sizing:border-box;padding:1px;border:1px;display:block;width:4px;margin-top:1%;position:absolute;top:1%;", b.boxSizing = d.offsetWidth === 4, b.doesNotIncludeMarginInBodyOffset = i.offsetTop !== 1, a.getComputedStyle && (b.pixelPosition = (a.getComputedStyle(d, null) || {}).top !== "1%", b.boxSizingReliable = (a.getComputedStyle(d, null) || { width: "4px" }).width === "4px", g = e.createElement("div"), g.style.cssText = d.style.cssText = h, g.style.marginRight = g.style.width = "0", d.style.width = "1px", d.appendChild(g), b.reliableMarginRight = !parseFloat((a.getComputedStyle(g, null) || {}).marginRight)), typeof d.style.zoom != "undefined" && (d.innerHTML = "", d.style.cssText = h + "width:1px;padding:1px;display:inline;zoom:1", b.inlineBlockNeedsLayout = d.offsetWidth === 3, d.style.display = "block", d.style.overflow = "visible", d.innerHTML = "<div></div>", d.firstChild.style.width = "5px", b.shrinkWrapBlocks = d.offsetWidth !== 3, c.style.zoom = 1), i.removeChild(c), c = d = f = g = null }), i.removeChild(n), c = d = f = g = h = i = n = null, b } (); var H = /(?:\{[\s\S]*\}|\[[\s\S]*\])$/, I = /([A-Z])/g; p.extend({ cache: {}, deletedIds: [], uuid: 0, expando: "jQuery" + (p.fn.jquery + Math.random()).replace(/\D/g, ""), noData: { embed: !0, object: "clsid:D27CDB6E-AE6D-11cf-96B8-444553540000", applet: !0 }, hasData: function (a) { return a = a.nodeType ? p.cache[a[p.expando]] : a[p.expando], !!a && !K(a) }, data: function (a, c, d, e) { if (!p.acceptData(a)) return; var f, g, h = p.expando, i = typeof c == "string", j = a.nodeType, k = j ? p.cache : a, l = j ? a[h] : a[h] && h; if ((!l || !k[l] || !e && !k[l].data) && i && d === b) return; l || (j ? a[h] = l = p.deletedIds.pop() || p.guid++ : l = h), k[l] || (k[l] = {}, j || (k[l].toJSON = p.noop)); if (typeof c == "object" || typeof c == "function") e ? k[l] = p.extend(k[l], c) : k[l].data = p.extend(k[l].data, c); return f = k[l], e || (f.data || (f.data = {}), f = f.data), d !== b && (f[p.camelCase(c)] = d), i ? (g = f[c], g == null && (g = f[p.camelCase(c)])) : g = f, g }, removeData: function (a, b, c) { if (!p.acceptData(a)) return; var d, e, f, g = a.nodeType, h = g ? p.cache : a, i = g ? a[p.expando] : p.expando; if (!h[i]) return; if (b) { d = c ? h[i] : h[i].data; if (d) { p.isArray(b) || (b in d ? b = [b] : (b = p.camelCase(b), b in d ? b = [b] : b = b.split(" "))); for (e = 0, f = b.length; e < f; e++) delete d[b[e]]; if (!(c ? K : p.isEmptyObject)(d)) return } } if (!c) { delete h[i].data; if (!K(h[i])) return } g ? p.cleanData([a], !0) : p.support.deleteExpando || h != h.window ? delete h[i] : h[i] = null }, _data: function (a, b, c) { return p.data(a, b, c, !0) }, acceptData: function (a) { var b = a.nodeName && p.noData[a.nodeName.toLowerCase()]; return !b || b !== !0 && a.getAttribute("classid") === b } }), p.fn.extend({ data: function (a, c) { var d, e, f, g, h, i = this[0], j = 0, k = null; if (a === b) { if (this.length) { k = p.data(i); if (i.nodeType === 1 && !p._data(i, "parsedAttrs")) { f = i.attributes; for (h = f.length; j < h; j++) g = f[j].name, g.indexOf("data-") || (g = p.camelCase(g.substring(5)), J(i, g, k[g])); p._data(i, "parsedAttrs", !0) } } return k } return typeof a == "object" ? this.each(function () { p.data(this, a) }) : (d = a.split(".", 2), d[1] = d[1] ? "." + d[1] : "", e = d[1] + "!", p.access(this, function (c) { if (c === b) return k = this.triggerHandler("getData" + e, [d[0]]), k === b && i && (k = p.data(i, a), k = J(i, a, k)), k === b && d[1] ? this.data(d[0]) : k; d[1] = c, this.each(function () { var b = p(this); b.triggerHandler("setData" + e, d), p.data(this, a, c), b.triggerHandler("changeData" + e, d) }) }, null, c, arguments.length > 1, null, !1)) }, removeData: function (a) { return this.each(function () { p.removeData(this, a) }) } }), p.extend({ queue: function (a, b, c) { var d; if (a) return b = (b || "fx") + "queue", d = p._data(a, b), c && (!d || p.isArray(c) ? d = p._data(a, b, p.makeArray(c)) : d.push(c)), d || [] }, dequeue: function (a, b) { b = b || "fx"; var c = p.queue(a, b), d = c.length, e = c.shift(), f = p._queueHooks(a, b), g = function () { p.dequeue(a, b) }; e === "inprogress" && (e = c.shift(), d--), e && (b === "fx" && c.unshift("inprogress"), delete f.stop, e.call(a, g, f)), !d && f && f.empty.fire() }, _queueHooks: function (a, b) { var c = b + "queueHooks"; return p._data(a, c) || p._data(a, c, { empty: p.Callbacks("once memory").add(function () { p.removeData(a, b + "queue", !0), p.removeData(a, c, !0) }) }) } }), p.fn.extend({ queue: function (a, c) { var d = 2; return typeof a != "string" && (c = a, a = "fx", d--), arguments.length < d ? p.queue(this[0], a) : c === b ? this : this.each(function () { var b = p.queue(this, a, c); p._queueHooks(this, a), a === "fx" && b[0] !== "inprogress" && p.dequeue(this, a) }) }, dequeue: function (a) { return this.each(function () { p.dequeue(this, a) }) }, delay: function (a, b) { return a = p.fx ? p.fx.speeds[a] || a : a, b = b || "fx", this.queue(b, function (b, c) { var d = setTimeout(b, a); c.stop = function () { clearTimeout(d) } }) }, clearQueue: function (a) { return this.queue(a || "fx", []) }, promise: function (a, c) { var d, e = 1, f = p.Deferred(), g = this, h = this.length, i = function () { --e || f.resolveWith(g, [g]) }; typeof a != "string" && (c = a, a = b), a = a || "fx"; while (h--) d = p._data(g[h], a + "queueHooks"), d && d.empty && (e++, d.empty.add(i)); return i(), f.promise(c) } }); var L, M, N, O = /[\t\r\n]/g, P = /\r/g, Q = /^(?:button|input)$/i, R = /^(?:button|input|object|select|textarea)$/i, S = /^a(?:rea|)$/i, T = /^(?:autofocus|autoplay|async|checked|controls|defer|disabled|hidden|loop|multiple|open|readonly|required|scoped|selected)$/i, U = p.support.getSetAttribute; p.fn.extend({ attr: function (a, b) { return p.access(this, p.attr, a, b, arguments.length > 1) }, removeAttr: function (a) { return this.each(function () { p.removeAttr(this, a) }) }, prop: function (a, b) { return p.access(this, p.prop, a, b, arguments.length > 1) }, removeProp: function (a) { return a = p.propFix[a] || a, this.each(function () { try { this[a] = b, delete this[a] } catch (c) { } }) }, addClass: function (a) { var b, c, d, e, f, g, h; if (p.isFunction(a)) return this.each(function (b) { p(this).addClass(a.call(this, b, this.className)) }); if (a && typeof a == "string") { b = a.split(s); for (c = 0, d = this.length; c < d; c++) { e = this[c]; if (e.nodeType === 1) if (!e.className && b.length === 1) e.className = a; else { f = " " + e.className + " "; for (g = 0, h = b.length; g < h; g++) f.indexOf(" " + b[g] + " ") < 0 && (f += b[g] + " "); e.className = p.trim(f) } } } return this }, removeClass: function (a) { var c, d, e, f, g, h, i; if (p.isFunction(a)) return this.each(function (b) { p(this).removeClass(a.call(this, b, this.className)) }); if (a && typeof a == "string" || a === b) { c = (a || "").split(s); for (h = 0, i = this.length; h < i; h++) { e = this[h]; if (e.nodeType === 1 && e.className) { d = (" " + e.className + " ").replace(O, " "); for (f = 0, g = c.length; f < g; f++) while (d.indexOf(" " + c[f] + " ") >= 0) d = d.replace(" " + c[f] + " ", " "); e.className = a ? p.trim(d) : "" } } } return this }, toggleClass: function (a, b) { var c = typeof a, d = typeof b == "boolean"; return p.isFunction(a) ? this.each(function (c) { p(this).toggleClass(a.call(this, c, this.className, b), b) }) : this.each(function () { if (c === "string") { var e, f = 0, g = p(this), h = b, i = a.split(s); while (e = i[f++]) h = d ? h : !g.hasClass(e), g[h ? "addClass" : "removeClass"](e) } else if (c === "undefined" || c === "boolean") this.className && p._data(this, "__className__", this.className), this.className = this.className || a === !1 ? "" : p._data(this, "__className__") || "" }) }, hasClass: function (a) { var b = " " + a + " ", c = 0, d = this.length; for (; c < d; c++) if (this[c].nodeType === 1 && (" " + this[c].className + " ").replace(O, " ").indexOf(b) >= 0) return !0; return !1 }, val: function (a) { var c, d, e, f = this[0]; if (!arguments.length) { if (f) return c = p.valHooks[f.type] || p.valHooks[f.nodeName.toLowerCase()], c && "get" in c && (d = c.get(f, "value")) !== b ? d : (d = f.value, typeof d == "string" ? d.replace(P, "") : d == null ? "" : d); return } return e = p.isFunction(a), this.each(function (d) { var f, g = p(this); if (this.nodeType !== 1) return; e ? f = a.call(this, d, g.val()) : f = a, f == null ? f = "" : typeof f == "number" ? f += "" : p.isArray(f) && (f = p.map(f, function (a) { return a == null ? "" : a + "" })), c = p.valHooks[this.type] || p.valHooks[this.nodeName.toLowerCase()]; if (!c || !("set" in c) || c.set(this, f, "value") === b) this.value = f }) } }), p.extend({ valHooks: { option: { get: function (a) { var b = a.attributes.value; return !b || b.specified ? a.value : a.text } }, select: { get: function (a) { var b, c, d, e, f = a.selectedIndex, g = [], h = a.options, i = a.type === "select-one"; if (f < 0) return null; c = i ? f : 0, d = i ? f + 1 : h.length; for (; c < d; c++) { e = h[c]; if (e.selected && (p.support.optDisabled ? !e.disabled : e.getAttribute("disabled") === null) && (!e.parentNode.disabled || !p.nodeName(e.parentNode, "optgroup"))) { b = p(e).val(); if (i) return b; g.push(b) } } return i && !g.length && h.length ? p(h[f]).val() : g }, set: function (a, b) { var c = p.makeArray(b); return p(a).find("option").each(function () { this.selected = p.inArray(p(this).val(), c) >= 0 }), c.length || (a.selectedIndex = -1), c } } }, attrFn: {}, attr: function (a, c, d, e) { var f, g, h, i = a.nodeType; if (!a || i === 3 || i === 8 || i === 2) return; if (e && p.isFunction(p.fn[c])) return p(a)[c](d); if (typeof a.getAttribute == "undefined") return p.prop(a, c, d); h = i !== 1 || !p.isXMLDoc(a), h && (c = c.toLowerCase(), g = p.attrHooks[c] || (T.test(c) ? M : L)); if (d !== b) { if (d === null) { p.removeAttr(a, c); return } return g && "set" in g && h && (f = g.set(a, d, c)) !== b ? f : (a.setAttribute(c, d + ""), d) } return g && "get" in g && h && (f = g.get(a, c)) !== null ? f : (f = a.getAttribute(c), f === null ? b : f) }, removeAttr: function (a, b) { var c, d, e, f, g = 0; if (b && a.nodeType === 1) { d = b.split(s); for (; g < d.length; g++) e = d[g], e && (c = p.propFix[e] || e, f = T.test(e), f || p.attr(a, e, ""), a.removeAttribute(U ? e : c), f && c in a && (a[c] = !1)) } }, attrHooks: { type: { set: function (a, b) { if (Q.test(a.nodeName) && a.parentNode) p.error("type property can't be changed"); else if (!p.support.radioValue && b === "radio" && p.nodeName(a, "input")) { var c = a.value; return a.setAttribute("type", b), c && (a.value = c), b } } }, value: { get: function (a, b) { return L && p.nodeName(a, "button") ? L.get(a, b) : b in a ? a.value : null }, set: function (a, b, c) { if (L && p.nodeName(a, "button")) return L.set(a, b, c); a.value = b } } }, propFix: { tabindex: "tabIndex", readonly: "readOnly", "for": "htmlFor", "class": "className", maxlength: "maxLength", cellspacing: "cellSpacing", cellpadding: "cellPadding", rowspan: "rowSpan", colspan: "colSpan", usemap: "useMap", frameborder: "frameBorder", contenteditable: "contentEditable" }, prop: function (a, c, d) { var e, f, g, h = a.nodeType; if (!a || h === 3 || h === 8 || h === 2) return; return g = h !== 1 || !p.isXMLDoc(a), g && (c = p.propFix[c] || c, f = p.propHooks[c]), d !== b ? f && "set" in f && (e = f.set(a, d, c)) !== b ? e : a[c] = d : f && "get" in f && (e = f.get(a, c)) !== null ? e : a[c] }, propHooks: { tabIndex: { get: function (a) { var c = a.getAttributeNode("tabindex"); return c && c.specified ? parseInt(c.value, 10) : R.test(a.nodeName) || S.test(a.nodeName) && a.href ? 0 : b } }} }), M = { get: function (a, c) { var d, e = p.prop(a, c); return e === !0 || typeof e != "boolean" && (d = a.getAttributeNode(c)) && d.nodeValue !== !1 ? c.toLowerCase() : b }, set: function (a, b, c) { var d; return b === !1 ? p.removeAttr(a, c) : (d = p.propFix[c] || c, d in a && (a[d] = !0), a.setAttribute(c, c.toLowerCase())), c } }, U || (N = { name: !0, id: !0, coords: !0 }, L = p.valHooks.button = { get: function (a, c) { var d; return d = a.getAttributeNode(c), d && (N[c] ? d.value !== "" : d.specified) ? d.value : b }, set: function (a, b, c) { var d = a.getAttributeNode(c); return d || (d = e.createAttribute(c), a.setAttributeNode(d)), d.value = b + "" } }, p.each(["width", "height"], function (a, b) { p.attrHooks[b] = p.extend(p.attrHooks[b], { set: function (a, c) { if (c === "") return a.setAttribute(b, "auto"), c } }) }), p.attrHooks.contenteditable = { get: L.get, set: function (a, b, c) { b === "" && (b = "false"), L.set(a, b, c) } }), p.support.hrefNormalized || p.each(["href", "src", "width", "height"], function (a, c) { p.attrHooks[c] = p.extend(p.attrHooks[c], { get: function (a) { var d = a.getAttribute(c, 2); return d === null ? b : d } }) }), p.support.style || (p.attrHooks.style = { get: function (a) { return a.style.cssText.toLowerCase() || b }, set: function (a, b) { return a.style.cssText = b + "" } }), p.support.optSelected || (p.propHooks.selected = p.extend(p.propHooks.selected, { get: function (a) { var b = a.parentNode; return b && (b.selectedIndex, b.parentNode && b.parentNode.selectedIndex), null } })), p.support.enctype || (p.propFix.enctype = "encoding"), p.support.checkOn || p.each(["radio", "checkbox"], function () { p.valHooks[this] = { get: function (a) { return a.getAttribute("value") === null ? "on" : a.value } } }), p.each(["radio", "checkbox"], function () { p.valHooks[this] = p.extend(p.valHooks[this], { set: function (a, b) { if (p.isArray(b)) return a.checked = p.inArray(p(a).val(), b) >= 0 } }) }); var V = /^(?:textarea|input|select)$/i, W = /^([^\.]*|)(?:\.(.+)|)$/, X = /(?:^|\s)hover(\.\S+|)\b/, Y = /^key/, Z = /^(?:mouse|contextmenu)|click/, $ = /^(?:focusinfocus|focusoutblur)$/, _ = function (a) { return p.event.special.hover ? a : a.replace(X, "mouseenter$1 mouseleave$1") }; p.event = { add: function (a, c, d, e, f) { var g, h, i, j, k, l, m, n, o, q, r; if (a.nodeType === 3 || a.nodeType === 8 || !c || !d || !(g = p._data(a))) return; d.handler && (o = d, d = o.handler, f = o.selector), d.guid || (d.guid = p.guid++), i = g.events, i || (g.events = i = {}), h = g.handle, h || (g.handle = h = function (a) { return typeof p != "undefined" && (!a || p.event.triggered !== a.type) ? p.event.dispatch.apply(h.elem, arguments) : b }, h.elem = a), c = p.trim(_(c)).split(" "); for (j = 0; j < c.length; j++) { k = W.exec(c[j]) || [], l = k[1], m = (k[2] || "").split(".").sort(), r = p.event.special[l] || {}, l = (f ? r.delegateType : r.bindType) || l, r = p.event.special[l] || {}, n = p.extend({ type: l, origType: k[1], data: e, handler: d, guid: d.guid, selector: f, needsContext: f && p.expr.match.needsContext.test(f), namespace: m.join(".") }, o), q = i[l]; if (!q) { q = i[l] = [], q.delegateCount = 0; if (!r.setup || r.setup.call(a, e, m, h) === !1) a.addEventListener ? a.addEventListener(l, h, !1) : a.attachEvent && a.attachEvent("on" + l, h) } r.add && (r.add.call(a, n), n.handler.guid || (n.handler.guid = d.guid)), f ? q.splice(q.delegateCount++, 0, n) : q.push(n), p.event.global[l] = !0 } a = null }, global: {}, remove: function (a, b, c, d, e) { var f, g, h, i, j, k, l, m, n, o, q, r = p.hasData(a) && p._data(a); if (!r || !(m = r.events)) return; b = p.trim(_(b || "")).split(" "); for (f = 0; f < b.length; f++) { g = W.exec(b[f]) || [], h = i = g[1], j = g[2]; if (!h) { for (h in m) p.event.remove(a, h + b[f], c, d, !0); continue } n = p.event.special[h] || {}, h = (d ? n.delegateType : n.bindType) || h, o = m[h] || [], k = o.length, j = j ? new RegExp("(^|\\.)" + j.split(".").sort().join("\\.(?:.*\\.|)") + "(\\.|$)") : null; for (l = 0; l < o.length; l++) q = o[l], (e || i === q.origType) && (!c || c.guid === q.guid) && (!j || j.test(q.namespace)) && (!d || d === q.selector || d === "**" && q.selector) && (o.splice(l--, 1), q.selector && o.delegateCount--, n.remove && n.remove.call(a, q)); o.length === 0 && k !== o.length && ((!n.teardown || n.teardown.call(a, j, r.handle) === !1) && p.removeEvent(a, h, r.handle), delete m[h]) } p.isEmptyObject(m) && (delete r.handle, p.removeData(a, "events", !0)) }, customEvent: { getData: !0, setData: !0, changeData: !0 }, trigger: function (c, d, f, g) { if (!f || f.nodeType !== 3 && f.nodeType !== 8) { var h, i, j, k, l, m, n, o, q, r, s = c.type || c, t = []; if ($.test(s + p.event.triggered)) return; s.indexOf("!") >= 0 && (s = s.slice(0, -1), i = !0), s.indexOf(".") >= 0 && (t = s.split("."), s = t.shift(), t.sort()); if ((!f || p.event.customEvent[s]) && !p.event.global[s]) return; c = typeof c == "object" ? c[p.expando] ? c : new p.Event(s, c) : new p.Event(s), c.type = s, c.isTrigger = !0, c.exclusive = i, c.namespace = t.join("."), c.namespace_re = c.namespace ? new RegExp("(^|\\.)" + t.join("\\.(?:.*\\.|)") + "(\\.|$)") : null, m = s.indexOf(":") < 0 ? "on" + s : ""; if (!f) { h = p.cache; for (j in h) h[j].events && h[j].events[s] && p.event.trigger(c, d, h[j].handle.elem, !0); return } c.result = b, c.target || (c.target = f), d = d != null ? p.makeArray(d) : [], d.unshift(c), n = p.event.special[s] || {}; if (n.trigger && n.trigger.apply(f, d) === !1) return; q = [[f, n.bindType || s]]; if (!g && !n.noBubble && !p.isWindow(f)) { r = n.delegateType || s, k = $.test(r + s) ? f : f.parentNode; for (l = f; k; k = k.parentNode) q.push([k, r]), l = k; l === (f.ownerDocument || e) && q.push([l.defaultView || l.parentWindow || a, r]) } for (j = 0; j < q.length && !c.isPropagationStopped(); j++) k = q[j][0], c.type = q[j][1], o = (p._data(k, "events") || {})[c.type] && p._data(k, "handle"), o && o.apply(k, d), o = m && k[m], o && p.acceptData(k) && o.apply && o.apply(k, d) === !1 && c.preventDefault(); return c.type = s, !g && !c.isDefaultPrevented() && (!n._default || n._default.apply(f.ownerDocument, d) === !1) && (s !== "click" || !p.nodeName(f, "a")) && p.acceptData(f) && m && f[s] && (s !== "focus" && s !== "blur" || c.target.offsetWidth !== 0) && !p.isWindow(f) && (l = f[m], l && (f[m] = null), p.event.triggered = s, f[s](), p.event.triggered = b, l && (f[m] = l)), c.result } return }, dispatch: function (c) { c = p.event.fix(c || a.event); var d, e, f, g, h, i, j, l, m, n, o = (p._data(this, "events") || {})[c.type] || [], q = o.delegateCount, r = k.call(arguments), s = !c.exclusive && !c.namespace, t = p.event.special[c.type] || {}, u = []; r[0] = c, c.delegateTarget = this; if (t.preDispatch && t.preDispatch.call(this, c) === !1) return; if (q && (!c.button || c.type !== "click")) for (f = c.target; f != this; f = f.parentNode || this) if (f.disabled !== !0 || c.type !== "click") { h = {}, j = []; for (d = 0; d < q; d++) l = o[d], m = l.selector, h[m] === b && (h[m] = l.needsContext ? p(m, this).index(f) >= 0 : p.find(m, this, null, [f]).length), h[m] && j.push(l); j.length && u.push({ elem: f, matches: j }) } o.length > q && u.push({ elem: this, matches: o.slice(q) }); for (d = 0; d < u.length && !c.isPropagationStopped(); d++) { i = u[d], c.currentTarget = i.elem; for (e = 0; e < i.matches.length && !c.isImmediatePropagationStopped(); e++) { l = i.matches[e]; if (s || !c.namespace && !l.namespace || c.namespace_re && c.namespace_re.test(l.namespace)) c.data = l.data, c.handleObj = l, g = ((p.event.special[l.origType] || {}).handle || l.handler).apply(i.elem, r), g !== b && (c.result = g, g === !1 && (c.preventDefault(), c.stopPropagation())) } } return t.postDispatch && t.postDispatch.call(this, c), c.result }, props: "attrChange attrName relatedNode srcElement altKey bubbles cancelable ctrlKey currentTarget eventPhase metaKey relatedTarget shiftKey target timeStamp view which".split(" "), fixHooks: {}, keyHooks: { props: "char charCode key keyCode".split(" "), filter: function (a, b) { return a.which == null && (a.which = b.charCode != null ? b.charCode : b.keyCode), a } }, mouseHooks: { props: "button buttons clientX clientY fromElement offsetX offsetY pageX pageY screenX screenY toElement".split(" "), filter: function (a, c) { var d, f, g, h = c.button, i = c.fromElement; return a.pageX == null && c.clientX != null && (d = a.target.ownerDocument || e, f = d.documentElement, g = d.body, a.pageX = c.clientX + (f && f.scrollLeft || g && g.scrollLeft || 0) - (f && f.clientLeft || g && g.clientLeft || 0), a.pageY = c.clientY + (f && f.scrollTop || g && g.scrollTop || 0) - (f && f.clientTop || g && g.clientTop || 0)), !a.relatedTarget && i && (a.relatedTarget = i === a.target ? c.toElement : i), !a.which && h !== b && (a.which = h & 1 ? 1 : h & 2 ? 3 : h & 4 ? 2 : 0), a } }, fix: function (a) { if (a[p.expando]) return a; var b, c, d = a, f = p.event.fixHooks[a.type] || {}, g = f.props ? this.props.concat(f.props) : this.props; a = p.Event(d); for (b = g.length; b; ) c = g[--b], a[c] = d[c]; return a.target || (a.target = d.srcElement || e), a.target.nodeType === 3 && (a.target = a.target.parentNode), a.metaKey = !!a.metaKey, f.filter ? f.filter(a, d) : a }, special: { load: { noBubble: !0 }, focus: { delegateType: "focusin" }, blur: { delegateType: "focusout" }, beforeunload: { setup: function (a, b, c) { p.isWindow(this) && (this.onbeforeunload = c) }, teardown: function (a, b) { this.onbeforeunload === b && (this.onbeforeunload = null) } } }, simulate: function (a, b, c, d) { var e = p.extend(new p.Event, c, { type: a, isSimulated: !0, originalEvent: {} }); d ? p.event.trigger(e, null, b) : p.event.dispatch.call(b, e), e.isDefaultPrevented() && c.preventDefault() } }, p.event.handle = p.event.dispatch, p.removeEvent = e.removeEventListener ? function (a, b, c) { a.removeEventListener && a.removeEventListener(b, c, !1) } : function (a, b, c) { var d = "on" + b; a.detachEvent && (typeof a[d] == "undefined" && (a[d] = null), a.detachEvent(d, c)) }, p.Event = function (a, b) { if (this instanceof p.Event) a && a.type ? (this.originalEvent = a, this.type = a.type, this.isDefaultPrevented = a.defaultPrevented || a.returnValue === !1 || a.getPreventDefault && a.getPreventDefault() ? bb : ba) : this.type = a, b && p.extend(this, b), this.timeStamp = a && a.timeStamp || p.now(), this[p.expando] = !0; else return new p.Event(a, b) }, p.Event.prototype = { preventDefault: function () { this.isDefaultPrevented = bb; var a = this.originalEvent; if (!a) return; a.preventDefault ? a.preventDefault() : a.returnValue = !1 }, stopPropagation: function () { this.isPropagationStopped = bb; var a = this.originalEvent; if (!a) return; a.stopPropagation && a.stopPropagation(), a.cancelBubble = !0 }, stopImmediatePropagation: function () { this.isImmediatePropagationStopped = bb, this.stopPropagation() }, isDefaultPrevented: ba, isPropagationStopped: ba, isImmediatePropagationStopped: ba }, p.each({ mouseenter: "mouseover", mouseleave: "mouseout" }, function (a, b) { p.event.special[a] = { delegateType: b, bindType: b, handle: function (a) { var c, d = this, e = a.relatedTarget, f = a.handleObj, g = f.selector; if (!e || e !== d && !p.contains(d, e)) a.type = f.origType, c = f.handler.apply(this, arguments), a.type = b; return c } } }), p.support.submitBubbles || (p.event.special.submit = { setup: function () { if (p.nodeName(this, "form")) return !1; p.event.add(this, "click._submit keypress._submit", function (a) { var c = a.target, d = p.nodeName(c, "input") || p.nodeName(c, "button") ? c.form : b; d && !p._data(d, "_submit_attached") && (p.event.add(d, "submit._submit", function (a) { a._submit_bubble = !0 }), p._data(d, "_submit_attached", !0)) }) }, postDispatch: function (a) { a._submit_bubble && (delete a._submit_bubble, this.parentNode && !a.isTrigger && p.event.simulate("submit", this.parentNode, a, !0)) }, teardown: function () { if (p.nodeName(this, "form")) return !1; p.event.remove(this, "._submit") } }), p.support.changeBubbles || (p.event.special.change = { setup: function () { if (V.test(this.nodeName)) { if (this.type === "checkbox" || this.type === "radio") p.event.add(this, "propertychange._change", function (a) { a.originalEvent.propertyName === "checked" && (this._just_changed = !0) }), p.event.add(this, "click._change", function (a) { this._just_changed && !a.isTrigger && (this._just_changed = !1), p.event.simulate("change", this, a, !0) }); return !1 } p.event.add(this, "beforeactivate._change", function (a) { var b = a.target; V.test(b.nodeName) && !p._data(b, "_change_attached") && (p.event.add(b, "change._change", function (a) { this.parentNode && !a.isSimulated && !a.isTrigger && p.event.simulate("change", this.parentNode, a, !0) }), p._data(b, "_change_attached", !0)) }) }, handle: function (a) { var b = a.target; if (this !== b || a.isSimulated || a.isTrigger || b.type !== "radio" && b.type !== "checkbox") return a.handleObj.handler.apply(this, arguments) }, teardown: function () { return p.event.remove(this, "._change"), !V.test(this.nodeName) } }), p.support.focusinBubbles || p.each({ focus: "focusin", blur: "focusout" }, function (a, b) { var c = 0, d = function (a) { p.event.simulate(b, a.target, p.event.fix(a), !0) }; p.event.special[b] = { setup: function () { c++ === 0 && e.addEventListener(a, d, !0) }, teardown: function () { --c === 0 && e.removeEventListener(a, d, !0) } } }), p.fn.extend({ on: function (a, c, d, e, f) { var g, h; if (typeof a == "object") { typeof c != "string" && (d = d || c, c = b); for (h in a) this.on(h, c, d, a[h], f); return this } d == null && e == null ? (e = c, d = c = b) : e == null && (typeof c == "string" ? (e = d, d = b) : (e = d, d = c, c = b)); if (e === !1) e = ba; else if (!e) return this; return f === 1 && (g = e, e = function (a) { return p().off(a), g.apply(this, arguments) }, e.guid = g.guid || (g.guid = p.guid++)), this.each(function () { p.event.add(this, a, e, d, c) }) }, one: function (a, b, c, d) { return this.on(a, b, c, d, 1) }, off: function (a, c, d) { var e, f; if (a && a.preventDefault && a.handleObj) return e = a.handleObj, p(a.delegateTarget).off(e.namespace ? e.origType + "." + e.namespace : e.origType, e.selector, e.handler), this; if (typeof a == "object") { for (f in a) this.off(f, c, a[f]); return this } if (c === !1 || typeof c == "function") d = c, c = b; return d === !1 && (d = ba), this.each(function () { p.event.remove(this, a, d, c) }) }, bind: function (a, b, c) { return this.on(a, null, b, c) }, unbind: function (a, b) { return this.off(a, null, b) }, live: function (a, b, c) { return p(this.context).on(a, this.selector, b, c), this }, die: function (a, b) { return p(this.context).off(a, this.selector || "**", b), this }, delegate: function (a, b, c, d) { return this.on(b, a, c, d) }, undelegate: function (a, b, c) { return arguments.length === 1 ? this.off(a, "**") : this.off(b, a || "**", c) }, trigger: function (a, b) { return this.each(function () { p.event.trigger(a, b, this) }) }, triggerHandler: function (a, b) { if (this[0]) return p.event.trigger(a, b, this[0], !0) }, toggle: function (a) { var b = arguments, c = a.guid || p.guid++, d = 0, e = function (c) { var e = (p._data(this, "lastToggle" + a.guid) || 0) % d; return p._data(this, "lastToggle" + a.guid, e + 1), c.preventDefault(), b[e].apply(this, arguments) || !1 }; e.guid = c; while (d < b.length) b[d++].guid = c; return this.click(e) }, hover: function (a, b) { return this.mouseenter(a).mouseleave(b || a) } }), p.each("blur focus focusin focusout load resize scroll unload click dblclick mousedown mouseup mousemove mouseover mouseout mouseenter mouseleave change select submit keydown keypress keyup error contextmenu".split(" "), function (a, b) { p.fn[b] = function (a, c) { return c == null && (c = a, a = null), arguments.length > 0 ? this.on(b, null, a, c) : this.trigger(b) }, Y.test(b) && (p.event.fixHooks[b] = p.event.keyHooks), Z.test(b) && (p.event.fixHooks[b] = p.event.mouseHooks) }), function (a, b) { function bc(a, b, c, d) { c = c || [], b = b || r; var e, f, i, j, k = b.nodeType; if (!a || typeof a != "string") return c; if (k !== 1 && k !== 9) return []; i = g(b); if (!i && !d) if (e = P.exec(a)) if (j = e[1]) { if (k === 9) { f = b.getElementById(j); if (!f || !f.parentNode) return c; if (f.id === j) return c.push(f), c } else if (b.ownerDocument && (f = b.ownerDocument.getElementById(j)) && h(b, f) && f.id === j) return c.push(f), c } else { if (e[2]) return w.apply(c, x.call(b.getElementsByTagName(a), 0)), c; if ((j = e[3]) && _ && b.getElementsByClassName) return w.apply(c, x.call(b.getElementsByClassName(j), 0)), c } return bp(a.replace(L, "$1"), b, c, d, i) } function bd(a) { return function (b) { var c = b.nodeName.toLowerCase(); return c === "input" && b.type === a } } function be(a) { return function (b) { var c = b.nodeName.toLowerCase(); return (c === "input" || c === "button") && b.type === a } } function bf(a) { return z(function (b) { return b = +b, z(function (c, d) { var e, f = a([], c.length, b), g = f.length; while (g--) c[e = f[g]] && (c[e] = !(d[e] = c[e])) }) }) } function bg(a, b, c) { if (a === b) return c; var d = a.nextSibling; while (d) { if (d === b) return -1; d = d.nextSibling } return 1 } function bh(a, b) { var c, d, f, g, h, i, j, k = C[o][a]; if (k) return b ? 0 : k.slice(0); h = a, i = [], j = e.preFilter; while (h) { if (!c || (d = M.exec(h))) d && (h = h.slice(d[0].length)), i.push(f = []); c = !1; if (d = N.exec(h)) f.push(c = new q(d.shift())), h = h.slice(c.length), c.type = d[0].replace(L, " "); for (g in e.filter) (d = W[g].exec(h)) && (!j[g] || (d = j[g](d, r, !0))) && (f.push(c = new q(d.shift())), h = h.slice(c.length), c.type = g, c.matches = d); if (!c) break } return b ? h.length : h ? bc.error(a) : C(a, i).slice(0) } function bi(a, b, d) { var e = b.dir, f = d && b.dir === "parentNode", g = u++; return b.first ? function (b, c, d) { while (b = b[e]) if (f || b.nodeType === 1) return a(b, c, d) } : function (b, d, h) { if (!h) { var i, j = t + " " + g + " ", k = j + c; while (b = b[e]) if (f || b.nodeType === 1) { if ((i = b[o]) === k) return b.sizset; if (typeof i == "string" && i.indexOf(j) === 0) { if (b.sizset) return b } else { b[o] = k; if (a(b, d, h)) return b.sizset = !0, b; b.sizset = !1 } } } else while (b = b[e]) if (f || b.nodeType === 1) if (a(b, d, h)) return b } } function bj(a) { return a.length > 1 ? function (b, c, d) { var e = a.length; while (e--) if (!a[e](b, c, d)) return !1; return !0 } : a[0] } function bk(a, b, c, d, e) { var f, g = [], h = 0, i = a.length, j = b != null; for (; h < i; h++) if (f = a[h]) if (!c || c(f, d, e)) g.push(f), j && b.push(h); return g } function bl(a, b, c, d, e, f) { return d && !d[o] && (d = bl(d)), e && !e[o] && (e = bl(e, f)), z(function (f, g, h, i) { if (f && e) return; var j, k, l, m = [], n = [], o = g.length, p = f || bo(b || "*", h.nodeType ? [h] : h, [], f), q = a && (f || !b) ? bk(p, m, a, h, i) : p, r = c ? e || (f ? a : o || d) ? [] : g : q; c && c(q, r, h, i); if (d) { l = bk(r, n), d(l, [], h, i), j = l.length; while (j--) if (k = l[j]) r[n[j]] = !(q[n[j]] = k) } if (f) { j = a && r.length; while (j--) if (k = r[j]) f[m[j]] = !(g[m[j]] = k) } else r = bk(r === g ? r.splice(o, r.length) : r), e ? e(null, g, r, i) : w.apply(g, r) }) } function bm(a) { var b, c, d, f = a.length, g = e.relative[a[0].type], h = g || e.relative[" "], i = g ? 1 : 0, j = bi(function (a) { return a === b }, h, !0), k = bi(function (a) { return y.call(b, a) > -1 }, h, !0), m = [function (a, c, d) { return !g && (d || c !== l) || ((b = c).nodeType ? j(a, c, d) : k(a, c, d)) } ]; for (; i < f; i++) if (c = e.relative[a[i].type]) m = [bi(bj(m), c)]; else { c = e.filter[a[i].type].apply(null, a[i].matches); if (c[o]) { d = ++i; for (; d < f; d++) if (e.relative[a[d].type]) break; return bl(i > 1 && bj(m), i > 1 && a.slice(0, i - 1).join("").replace(L, "$1"), c, i < d && bm(a.slice(i, d)), d < f && bm(a = a.slice(d)), d < f && a.join("")) } m.push(c) } return bj(m) } function bn(a, b) { var d = b.length > 0, f = a.length > 0, g = function (h, i, j, k, m) { var n, o, p, q = [], s = 0, u = "0", x = h && [], y = m != null, z = l, A = h || f && e.find.TAG("*", m && i.parentNode || i), B = t += z == null ? 1 : Math.E; y && (l = i !== r && i, c = g.el); for (; (n = A[u]) != null; u++) { if (f && n) { for (o = 0; p = a[o]; o++) if (p(n, i, j)) { k.push(n); break } y && (t = B, c = ++g.el) } d && ((n = !p && n) && s--, h && x.push(n)) } s += u; if (d && u !== s) { for (o = 0; p = b[o]; o++) p(x, q, i, j); if (h) { if (s > 0) while (u--) !x[u] && !q[u] && (q[u] = v.call(k)); q = bk(q) } w.apply(k, q), y && !h && q.length > 0 && s + b.length > 1 && bc.uniqueSort(k) } return y && (t = B, l = z), x }; return g.el = 0, d ? z(g) : g } function bo(a, b, c, d) { var e = 0, f = b.length; for (; e < f; e++) bc(a, b[e], c, d); return c } function bp(a, b, c, d, f) { var g, h, j, k, l, m = bh(a), n = m.length; if (!d && m.length === 1) { h = m[0] = m[0].slice(0); if (h.length > 2 && (j = h[0]).type === "ID" && b.nodeType === 9 && !f && e.relative[h[1].type]) { b = e.find.ID(j.matches[0].replace(V, ""), b, f)[0]; if (!b) return c; a = a.slice(h.shift().length) } for (g = W.POS.test(a) ? -1 : h.length - 1; g >= 0; g--) { j = h[g]; if (e.relative[k = j.type]) break; if (l = e.find[k]) if (d = l(j.matches[0].replace(V, ""), R.test(h[0].type) && b.parentNode || b, f)) { h.splice(g, 1), a = d.length && h.join(""); if (!a) return w.apply(c, x.call(d, 0)), c; break } } } return i(a, m)(d, b, f, c, R.test(a)), c } function bq() { } var c, d, e, f, g, h, i, j, k, l, m = !0, n = "undefined", o = ("sizcache" + Math.random()).replace(".", ""), q = String, r = a.document, s = r.documentElement, t = 0, u = 0, v = [].pop, w = [].push, x = [].slice, y = [].indexOf || function (a) { var b = 0, c = this.length; for (; b < c; b++) if (this[b] === a) return b; return -1 }, z = function (a, b) { return a[o] = b == null || b, a }, A = function () { var a = {}, b = []; return z(function (c, d) { return b.push(c) > e.cacheLength && delete a[b.shift()], a[c] = d }, a) }, B = A(), C = A(), D = A(), E = "[\\x20\\t\\r\\n\\f]", F = "(?:\\\\.|[-\\w]|[^\\x00-\\xa0])+", G = F.replace("w", "w#"), H = "([*^$|!~]?=)", I = "\\[" + E + "*(" + F + ")" + E + "*(?:" + H + E + "*(?:(['\"])((?:\\\\.|[^\\\\])*?)\\3|(" + G + ")|)|)" + E + "*\\]", J = ":(" + F + ")(?:\\((?:(['\"])((?:\\\\.|[^\\\\])*?)\\2|([^()[\\]]*|(?:(?:" + I + ")|[^:]|\\\\.)*|.*))\\)|)", K = ":(even|odd|eq|gt|lt|nth|first|last)(?:\\(" + E + "*((?:-\\d)?\\d*)" + E + "*\\)|)(?=[^-]|$)", L = new RegExp("^" + E + "+|((?:^|[^\\\\])(?:\\\\.)*)" + E + "+$", "g"), M = new RegExp("^" + E + "*," + E + "*"), N = new RegExp("^" + E + "*([\\x20\\t\\r\\n\\f>+~])" + E + "*"), O = new RegExp(J), P = /^(?:#([\w\-]+)|(\w+)|\.([\w\-]+))$/, Q = /^:not/, R = /[\x20\t\r\n\f]*[+~]/, S = /:not\($/, T = /h\d/i, U = /input|select|textarea|button/i, V = /\\(?!\\)/g, W = { ID: new RegExp("^#(" + F + ")"), CLASS: new RegExp("^\\.(" + F + ")"), NAME: new RegExp("^\\[name=['\"]?(" + F + ")['\"]?\\]"), TAG: new RegExp("^(" + F.replace("w", "w*") + ")"), ATTR: new RegExp("^" + I), PSEUDO: new RegExp("^" + J), POS: new RegExp(K, "i"), CHILD: new RegExp("^:(only|nth|first|last)-child(?:\\(" + E + "*(even|odd|(([+-]|)(\\d*)n|)" + E + "*(?:([+-]|)" + E + "*(\\d+)|))" + E + "*\\)|)", "i"), needsContext: new RegExp("^" + E + "*[>+~]|" + K, "i") }, X = function (a) { var b = r.createElement("div"); try { return a(b) } catch (c) { return !1 } finally { b = null } }, Y = X(function (a) { return a.appendChild(r.createComment("")), !a.getElementsByTagName("*").length }), Z = X(function (a) { return a.innerHTML = "<a href='#'></a>", a.firstChild && typeof a.firstChild.getAttribute !== n && a.firstChild.getAttribute("href") === "#" }), $ = X(function (a) { a.innerHTML = "<select></select>"; var b = typeof a.lastChild.getAttribute("multiple"); return b !== "boolean" && b !== "string" }), _ = X(function (a) { return a.innerHTML = "<div class='hidden e'></div><div class='hidden'></div>", !a.getElementsByClassName || !a.getElementsByClassName("e").length ? !1 : (a.lastChild.className = "e", a.getElementsByClassName("e").length === 2) }), ba = X(function (a) { a.id = o + 0, a.innerHTML = "<a name='" + o + "'></a><div name='" + o + "'></div>", s.insertBefore(a, s.firstChild); var b = r.getElementsByName && r.getElementsByName(o).length === 2 + r.getElementsByName(o + 0).length; return d = !r.getElementById(o), s.removeChild(a), b }); try { x.call(s.childNodes, 0)[0].nodeType } catch (bb) { x = function (a) { var b, c = []; for (; b = this[a]; a++) c.push(b); return c } } bc.matches = function (a, b) { return bc(a, null, null, b) }, bc.matchesSelector = function (a, b) { return bc(b, null, null, [a]).length > 0 }, f = bc.getText = function (a) { var b, c = "", d = 0, e = a.nodeType; if (e) { if (e === 1 || e === 9 || e === 11) { if (typeof a.textContent == "string") return a.textContent; for (a = a.firstChild; a; a = a.nextSibling) c += f(a) } else if (e === 3 || e === 4) return a.nodeValue } else for (; b = a[d]; d++) c += f(b); return c }, g = bc.isXML = function (a) { var b = a && (a.ownerDocument || a).documentElement; return b ? b.nodeName !== "HTML" : !1 }, h = bc.contains = s.contains ? function (a, b) { var c = a.nodeType === 9 ? a.documentElement : a, d = b && b.parentNode; return a === d || !!(d && d.nodeType === 1 && c.contains && c.contains(d)) } : s.compareDocumentPosition ? function (a, b) { return b && !!(a.compareDocumentPosition(b) & 16) } : function (a, b) { while (b = b.parentNode) if (b === a) return !0; return !1 }, bc.attr = function (a, b) { var c, d = g(a); return d || (b = b.toLowerCase()), (c = e.attrHandle[b]) ? c(a) : d || $ ? a.getAttribute(b) : (c = a.getAttributeNode(b), c ? typeof a[b] == "boolean" ? a[b] ? b : null : c.specified ? c.value : null : null) }, e = bc.selectors = { cacheLength: 50, createPseudo: z, match: W, attrHandle: Z ? {} : { href: function (a) { return a.getAttribute("href", 2) }, type: function (a) { return a.getAttribute("type") } }, find: { ID: d ? function (a, b, c) { if (typeof b.getElementById !== n && !c) { var d = b.getElementById(a); return d && d.parentNode ? [d] : [] } } : function (a, c, d) { if (typeof c.getElementById !== n && !d) { var e = c.getElementById(a); return e ? e.id === a || typeof e.getAttributeNode !== n && e.getAttributeNode("id").value === a ? [e] : b : [] } }, TAG: Y ? function (a, b) { if (typeof b.getElementsByTagName !== n) return b.getElementsByTagName(a) } : function (a, b) { var c = b.getElementsByTagName(a); if (a === "*") { var d, e = [], f = 0; for (; d = c[f]; f++) d.nodeType === 1 && e.push(d); return e } return c }, NAME: ba && function (a, b) { if (typeof b.getElementsByName !== n) return b.getElementsByName(name) }, CLASS: _ && function (a, b, c) { if (typeof b.getElementsByClassName !== n && !c) return b.getElementsByClassName(a) } }, relative: { ">": { dir: "parentNode", first: !0 }, " ": { dir: "parentNode" }, "+": { dir: "previousSibling", first: !0 }, "~": { dir: "previousSibling"} }, preFilter: { ATTR: function (a) { return a[1] = a[1].replace(V, ""), a[3] = (a[4] || a[5] || "").replace(V, ""), a[2] === "~=" && (a[3] = " " + a[3] + " "), a.slice(0, 4) }, CHILD: function (a) { return a[1] = a[1].toLowerCase(), a[1] === "nth" ? (a[2] || bc.error(a[0]), a[3] = +(a[3] ? a[4] + (a[5] || 1) : 2 * (a[2] === "even" || a[2] === "odd")), a[4] = +(a[6] + a[7] || a[2] === "odd")) : a[2] && bc.error(a[0]), a }, PSEUDO: function (a) { var b, c; if (W.CHILD.test(a[0])) return null; if (a[3]) a[2] = a[3]; else if (b = a[4]) O.test(b) && (c = bh(b, !0)) && (c = b.indexOf(")", b.length - c) - b.length) && (b = b.slice(0, c), a[0] = a[0].slice(0, c)), a[2] = b; return a.slice(0, 3) } }, filter: { ID: d ? function (a) { return a = a.replace(V, ""), function (b) { return b.getAttribute("id") === a } } : function (a) { return a = a.replace(V, ""), function (b) { var c = typeof b.getAttributeNode !== n && b.getAttributeNode("id"); return c && c.value === a } }, TAG: function (a) { return a === "*" ? function () { return !0 } : (a = a.replace(V, "").toLowerCase(), function (b) { return b.nodeName && b.nodeName.toLowerCase() === a }) }, CLASS: function (a) { var b = B[o][a]; return b || (b = B(a, new RegExp("(^|" + E + ")" + a + "(" + E + "|$)"))), function (a) { return b.test(a.className || typeof a.getAttribute !== n && a.getAttribute("class") || "") } }, ATTR: function (a, b, c) { return function (d, e) { var f = bc.attr(d, a); return f == null ? b === "!=" : b ? (f += "", b === "=" ? f === c : b === "!=" ? f !== c : b === "^=" ? c && f.indexOf(c) === 0 : b === "*=" ? c && f.indexOf(c) > -1 : b === "$=" ? c && f.substr(f.length - c.length) === c : b === "~=" ? (" " + f + " ").indexOf(c) > -1 : b === "|=" ? f === c || f.substr(0, c.length + 1) === c + "-" : !1) : !0 } }, CHILD: function (a, b, c, d) { return a === "nth" ? function (a) { var b, e, f = a.parentNode; if (c === 1 && d === 0) return !0; if (f) { e = 0; for (b = f.firstChild; b; b = b.nextSibling) if (b.nodeType === 1) { e++; if (a === b) break } } return e -= d, e === c || e % c === 0 && e / c >= 0 } : function (b) { var c = b; switch (a) { case "only": case "first": while (c = c.previousSibling) if (c.nodeType === 1) return !1; if (a === "first") return !0; c = b; case "last": while (c = c.nextSibling) if (c.nodeType === 1) return !1; return !0 } } }, PSEUDO: function (a, b) { var c, d = e.pseudos[a] || e.setFilters[a.toLowerCase()] || bc.error("unsupported pseudo: " + a); return d[o] ? d(b) : d.length > 1 ? (c = [a, a, "", b], e.setFilters.hasOwnProperty(a.toLowerCase()) ? z(function (a, c) { var e, f = d(a, b), g = f.length; while (g--) e = y.call(a, f[g]), a[e] = !(c[e] = f[g]) }) : function (a) { return d(a, 0, c) }) : d } }, pseudos: { not: z(function (a) { var b = [], c = [], d = i(a.replace(L, "$1")); return d[o] ? z(function (a, b, c, e) { var f, g = d(a, null, e, []), h = a.length; while (h--) if (f = g[h]) a[h] = !(b[h] = f) }) : function (a, e, f) { return b[0] = a, d(b, null, f, c), !c.pop() } }), has: z(function (a) { return function (b) { return bc(a, b).length > 0 } }), contains: z(function (a) { return function (b) { return (b.textContent || b.innerText || f(b)).indexOf(a) > -1 } }), enabled: function (a) { return a.disabled === !1 }, disabled: function (a) { return a.disabled === !0 }, checked: function (a) { var b = a.nodeName.toLowerCase(); return b === "input" && !!a.checked || b === "option" && !!a.selected }, selected: function (a) { return a.parentNode && a.parentNode.selectedIndex, a.selected === !0 }, parent: function (a) { return !e.pseudos.empty(a) }, empty: function (a) { var b; a = a.firstChild; while (a) { if (a.nodeName > "@" || (b = a.nodeType) === 3 || b === 4) return !1; a = a.nextSibling } return !0 }, header: function (a) { return T.test(a.nodeName) }, text: function (a) { var b, c; return a.nodeName.toLowerCase() === "input" && (b = a.type) === "text" && ((c = a.getAttribute("type")) == null || c.toLowerCase() === b) }, radio: bd("radio"), checkbox: bd("checkbox"), file: bd("file"), password: bd("password"), image: bd("image"), submit: be("submit"), reset: be("reset"), button: function (a) { var b = a.nodeName.toLowerCase(); return b === "input" && a.type === "button" || b === "button" }, input: function (a) { return U.test(a.nodeName) }, focus: function (a) { var b = a.ownerDocument; return a === b.activeElement && (!b.hasFocus || b.hasFocus()) && (!!a.type || !!a.href) }, active: function (a) { return a === a.ownerDocument.activeElement }, first: bf(function (a, b, c) { return [0] }), last: bf(function (a, b, c) { return [b - 1] }), eq: bf(function (a, b, c) { return [c < 0 ? c + b : c] }), even: bf(function (a, b, c) { for (var d = 0; d < b; d += 2) a.push(d); return a }), odd: bf(function (a, b, c) { for (var d = 1; d < b; d += 2) a.push(d); return a }), lt: bf(function (a, b, c) { for (var d = c < 0 ? c + b : c; --d >= 0; ) a.push(d); return a }), gt: bf(function (a, b, c) { for (var d = c < 0 ? c + b : c; ++d < b; ) a.push(d); return a })} }, j = s.compareDocumentPosition ? function (a, b) { return a === b ? (k = !0, 0) : (!a.compareDocumentPosition || !b.compareDocumentPosition ? a.compareDocumentPosition : a.compareDocumentPosition(b) & 4) ? -1 : 1 } : function (a, b) { if (a === b) return k = !0, 0; if (a.sourceIndex && b.sourceIndex) return a.sourceIndex - b.sourceIndex; var c, d, e = [], f = [], g = a.parentNode, h = b.parentNode, i = g; if (g === h) return bg(a, b); if (!g) return -1; if (!h) return 1; while (i) e.unshift(i), i = i.parentNode; i = h; while (i) f.unshift(i), i = i.parentNode; c = e.length, d = f.length; for (var j = 0; j < c && j < d; j++) if (e[j] !== f[j]) return bg(e[j], f[j]); return j === c ? bg(a, f[j], -1) : bg(e[j], b, 1) }, [0, 0].sort(j), m = !k, bc.uniqueSort = function (a) { var b, c = 1; k = m, a.sort(j); if (k) for (; b = a[c]; c++) b === a[c - 1] && a.splice(c--, 1); return a }, bc.error = function (a) { throw new Error("Syntax error, unrecognized expression: " + a) }, i = bc.compile = function (a, b) { var c, d = [], e = [], f = D[o][a]; if (!f) { b || (b = bh(a)), c = b.length; while (c--) f = bm(b[c]), f[o] ? d.push(f) : e.push(f); f = D(a, bn(e, d)) } return f }, r.querySelectorAll && function () { var a, b = bp, c = /'|\\/g, d = /\=[\x20\t\r\n\f]*([^'"\]]*)[\x20\t\r\n\f]*\]/g, e = [":focus"], f = [":active", ":focus"], h = s.matchesSelector || s.mozMatchesSelector || s.webkitMatchesSelector || s.oMatchesSelector || s.msMatchesSelector; X(function (a) { a.innerHTML = "<select><option selected=''></option></select>", a.querySelectorAll("[selected]").length || e.push("\\[" + E + "*(?:checked|disabled|ismap|multiple|readonly|selected|value)"), a.querySelectorAll(":checked").length || e.push(":checked") }), X(function (a) { a.innerHTML = "<p test=''></p>", a.querySelectorAll("[test^='']").length && e.push("[*^$]=" + E + "*(?:\"\"|'')"), a.innerHTML = "<input type='hidden'/>", a.querySelectorAll(":enabled").length || e.push(":enabled", ":disabled") }), e = new RegExp(e.join("|")), bp = function (a, d, f, g, h) { if (!g && !h && (!e || !e.test(a))) { var i, j, k = !0, l = o, m = d, n = d.nodeType === 9 && a; if (d.nodeType === 1 && d.nodeName.toLowerCase() !== "object") { i = bh(a), (k = d.getAttribute("id")) ? l = k.replace(c, "\\$&") : d.setAttribute("id", l), l = "[id='" + l + "'] ", j = i.length; while (j--) i[j] = l + i[j].join(""); m = R.test(a) && d.parentNode || d, n = i.join(",") } if (n) try { return w.apply(f, x.call(m.querySelectorAll(n), 0)), f } catch (p) { } finally { k || d.removeAttribute("id") } } return b(a, d, f, g, h) }, h && (X(function (b) { a = h.call(b, "div"); try { h.call(b, "[test!='']:sizzle"), f.push("!=", J) } catch (c) { } }), f = new RegExp(f.join("|")), bc.matchesSelector = function (b, c) { c = c.replace(d, "='$1']"); if (!g(b) && !f.test(c) && (!e || !e.test(c))) try { var i = h.call(b, c); if (i || a || b.document && b.document.nodeType !== 11) return i } catch (j) { } return bc(c, null, null, [b]).length > 0 }) } (), e.pseudos.nth = e.pseudos.eq, e.filters = bq.prototype = e.pseudos, e.setFilters = new bq, bc.attr = p.attr, p.find = bc, p.expr = bc.selectors, p.expr[":"] = p.expr.pseudos, p.unique = bc.uniqueSort, p.text = bc.getText, p.isXMLDoc = bc.isXML, p.contains = bc.contains } (a); var bc = /Until$/, bd = /^(?:parents|prev(?:Until|All))/, be = /^.[^:#\[\.,]*$/, bf = p.expr.match.needsContext, bg = { children: !0, contents: !0, next: !0, prev: !0 }; p.fn.extend({ find: function (a) { var b, c, d, e, f, g, h = this; if (typeof a != "string") return p(a).filter(function () { for (b = 0, c = h.length; b < c; b++) if (p.contains(h[b], this)) return !0 }); g = this.pushStack("", "find", a); for (b = 0, c = this.length; b < c; b++) { d = g.length, p.find(a, this[b], g); if (b > 0) for (e = d; e < g.length; e++) for (f = 0; f < d; f++) if (g[f] === g[e]) { g.splice(e--, 1); break } } return g }, has: function (a) { var b, c = p(a, this), d = c.length; return this.filter(function () { for (b = 0; b < d; b++) if (p.contains(this, c[b])) return !0 }) }, not: function (a) { return this.pushStack(bj(this, a, !1), "not", a) }, filter: function (a) { return this.pushStack(bj(this, a, !0), "filter", a) }, is: function (a) { return !!a && (typeof a == "string" ? bf.test(a) ? p(a, this.context).index(this[0]) >= 0 : p.filter(a, this).length > 0 : this.filter(a).length > 0) }, closest: function (a, b) { var c, d = 0, e = this.length, f = [], g = bf.test(a) || typeof a != "string" ? p(a, b || this.context) : 0; for (; d < e; d++) { c = this[d]; while (c && c.ownerDocument && c !== b && c.nodeType !== 11) { if (g ? g.index(c) > -1 : p.find.matchesSelector(c, a)) { f.push(c); break } c = c.parentNode } } return f = f.length > 1 ? p.unique(f) : f, this.pushStack(f, "closest", a) }, index: function (a) { return a ? typeof a == "string" ? p.inArray(this[0], p(a)) : p.inArray(a.jquery ? a[0] : a, this) : this[0] && this[0].parentNode ? this.prevAll().length : -1 }, add: function (a, b) { var c = typeof a == "string" ? p(a, b) : p.makeArray(a && a.nodeType ? [a] : a), d = p.merge(this.get(), c); return this.pushStack(bh(c[0]) || bh(d[0]) ? d : p.unique(d)) }, addBack: function (a) { return this.add(a == null ? this.prevObject : this.prevObject.filter(a)) } }), p.fn.andSelf = p.fn.addBack, p.each({ parent: function (a) { var b = a.parentNode; return b && b.nodeType !== 11 ? b : null }, parents: function (a) { return p.dir(a, "parentNode") }, parentsUntil: function (a, b, c) { return p.dir(a, "parentNode", c) }, next: function (a) { return bi(a, "nextSibling") }, prev: function (a) { return bi(a, "previousSibling") }, nextAll: function (a) { return p.dir(a, "nextSibling") }, prevAll: function (a) { return p.dir(a, "previousSibling") }, nextUntil: function (a, b, c) { return p.dir(a, "nextSibling", c) }, prevUntil: function (a, b, c) { return p.dir(a, "previousSibling", c) }, siblings: function (a) { return p.sibling((a.parentNode || {}).firstChild, a) }, children: function (a) { return p.sibling(a.firstChild) }, contents: function (a) { return p.nodeName(a, "iframe") ? a.contentDocument || a.contentWindow.document : p.merge([], a.childNodes) } }, function (a, b) { p.fn[a] = function (c, d) { var e = p.map(this, b, c); return bc.test(a) || (d = c), d && typeof d == "string" && (e = p.filter(d, e)), e = this.length > 1 && !bg[a] ? p.unique(e) : e, this.length > 1 && bd.test(a) && (e = e.reverse()), this.pushStack(e, a, k.call(arguments).join(",")) } }), p.extend({ filter: function (a, b, c) { return c && (a = ":not(" + a + ")"), b.length === 1 ? p.find.matchesSelector(b[0], a) ? [b[0]] : [] : p.find.matches(a, b) }, dir: function (a, c, d) { var e = [], f = a[c]; while (f && f.nodeType !== 9 && (d === b || f.nodeType !== 1 || !p(f).is(d))) f.nodeType === 1 && e.push(f), f = f[c]; return e }, sibling: function (a, b) { var c = []; for (; a; a = a.nextSibling) a.nodeType === 1 && a !== b && c.push(a); return c } }); var bl = "abbr|article|aside|audio|bdi|canvas|data|datalist|details|figcaption|figure|footer|header|hgroup|mark|meter|nav|output|progress|section|summary|time|video", bm = / jQuery\d+="(?:null|\d+)"/g, bn = /^\s+/, bo = /<(?!area|br|col|embed|hr|img|input|link|meta|param)(([\w:]+)[^>]*)\/>/gi, bp = /<([\w:]+)/, bq = /<tbody/i, br = /<|&#?\w+;/, bs = /<(?:script|style|link)/i, bt = /<(?:script|object|embed|option|style)/i, bu = new RegExp("<(?:" + bl + ")[\\s/>]", "i"), bv = /^(?:checkbox|radio)$/, bw = /checked\s*(?:[^=]|=\s*.checked.)/i, bx = /\/(java|ecma)script/i, by = /^\s*<!(?:\[CDATA\[|\-\-)|[\]\-]{2}>\s*$/g, bz = { option: [1, "<select multiple='multiple'>", "</select>"], legend: [1, "<fieldset>", "</fieldset>"], thead: [1, "<table>", "</table>"], tr: [2, "<table><tbody>", "</tbody></table>"], td: [3, "<table><tbody><tr>", "</tr></tbody></table>"], col: [2, "<table><tbody></tbody><colgroup>", "</colgroup></table>"], area: [1, "<map>", "</map>"], _default: [0, "", ""] }, bA = bk(e), bB = bA.appendChild(e.createElement("div")); bz.optgroup = bz.option, bz.tbody = bz.tfoot = bz.colgroup = bz.caption = bz.thead, bz.th = bz.td, p.support.htmlSerialize || (bz._default = [1, "X<div>", "</div>"]), p.fn.extend({ text: function (a) { return p.access(this, function (a) { return a === b ? p.text(this) : this.empty().append((this[0] && this[0].ownerDocument || e).createTextNode(a)) }, null, a, arguments.length) }, wrapAll: function (a) { if (p.isFunction(a)) return this.each(function (b) { p(this).wrapAll(a.call(this, b)) }); if (this[0]) { var b = p(a, this[0].ownerDocument).eq(0).clone(!0); this[0].parentNode && b.insertBefore(this[0]), b.map(function () { var a = this; while (a.firstChild && a.firstChild.nodeType === 1) a = a.firstChild; return a }).append(this) } return this }, wrapInner: function (a) { return p.isFunction(a) ? this.each(function (b) { p(this).wrapInner(a.call(this, b)) }) : this.each(function () { var b = p(this), c = b.contents(); c.length ? c.wrapAll(a) : b.append(a) }) }, wrap: function (a) { var b = p.isFunction(a); return this.each(function (c) { p(this).wrapAll(b ? a.call(this, c) : a) }) }, unwrap: function () { return this.parent().each(function () { p.nodeName(this, "body") || p(this).replaceWith(this.childNodes) }).end() }, append: function () { return this.domManip(arguments, !0, function (a) { (this.nodeType === 1 || this.nodeType === 11) && this.appendChild(a) }) }, prepend: function () { return this.domManip(arguments, !0, function (a) { (this.nodeType === 1 || this.nodeType === 11) && this.insertBefore(a, this.firstChild) }) }, before: function () { if (!bh(this[0])) return this.domManip(arguments, !1, function (a) { this.parentNode.insertBefore(a, this) }); if (arguments.length) { var a = p.clean(arguments); return this.pushStack(p.merge(a, this), "before", this.selector) } }, after: function () { if (!bh(this[0])) return this.domManip(arguments, !1, function (a) { this.parentNode.insertBefore(a, this.nextSibling) }); if (arguments.length) { var a = p.clean(arguments); return this.pushStack(p.merge(this, a), "after", this.selector) } }, remove: function (a, b) { var c, d = 0; for (; (c = this[d]) != null; d++) if (!a || p.filter(a, [c]).length) !b && c.nodeType === 1 && (p.cleanData(c.getElementsByTagName("*")), p.cleanData([c])), c.parentNode && c.parentNode.removeChild(c); return this }, empty: function () { var a, b = 0; for (; (a = this[b]) != null; b++) { a.nodeType === 1 && p.cleanData(a.getElementsByTagName("*")); while (a.firstChild) a.removeChild(a.firstChild) } return this }, clone: function (a, b) { return a = a == null ? !1 : a, b = b == null ? a : b, this.map(function () { return p.clone(this, a, b) }) }, html: function (a) { return p.access(this, function (a) { var c = this[0] || {}, d = 0, e = this.length; if (a === b) return c.nodeType === 1 ? c.innerHTML.replace(bm, "") : b; if (typeof a == "string" && !bs.test(a) && (p.support.htmlSerialize || !bu.test(a)) && (p.support.leadingWhitespace || !bn.test(a)) && !bz[(bp.exec(a) || ["", ""])[1].toLowerCase()]) { a = a.replace(bo, "<$1></$2>"); try { for (; d < e; d++) c = this[d] || {}, c.nodeType === 1 && (p.cleanData(c.getElementsByTagName("*")), c.innerHTML = a); c = 0 } catch (f) { } } c && this.empty().append(a) }, null, a, arguments.length) }, replaceWith: function (a) { return bh(this[0]) ? this.length ? this.pushStack(p(p.isFunction(a) ? a() : a), "replaceWith", a) : this : p.isFunction(a) ? this.each(function (b) { var c = p(this), d = c.html(); c.replaceWith(a.call(this, b, d)) }) : (typeof a != "string" && (a = p(a).detach()), this.each(function () { var b = this.nextSibling, c = this.parentNode; p(this).remove(), b ? p(b).before(a) : p(c).append(a) })) }, detach: function (a) { return this.remove(a, !0) }, domManip: function (a, c, d) { a = [].concat.apply([], a); var e, f, g, h, i = 0, j = a[0], k = [], l = this.length; if (!p.support.checkClone && l > 1 && typeof j == "string" && bw.test(j)) return this.each(function () { p(this).domManip(a, c, d) }); if (p.isFunction(j)) return this.each(function (e) { var f = p(this); a[0] = j.call(this, e, c ? f.html() : b), f.domManip(a, c, d) }); if (this[0]) { e = p.buildFragment(a, this, k), g = e.fragment, f = g.firstChild, g.childNodes.length === 1 && (g = f); if (f) { c = c && p.nodeName(f, "tr"); for (h = e.cacheable || l - 1; i < l; i++) d.call(c && p.nodeName(this[i], "table") ? bC(this[i], "tbody") : this[i], i === h ? g : p.clone(g, !0, !0)) } g = f = null, k.length && p.each(k, function (a, b) { b.src ? p.ajax ? p.ajax({ url: b.src, type: "GET", dataType: "script", async: !1, global: !1, "throws": !0 }) : p.error("no ajax") : p.globalEval((b.text || b.textContent || b.innerHTML || "").replace(by, "")), b.parentNode && b.parentNode.removeChild(b) }) } return this } }), p.buildFragment = function (a, c, d) { var f, g, h, i = a[0]; return c = c || e, c = !c.nodeType && c[0] || c, c = c.ownerDocument || c, a.length === 1 && typeof i == "string" && i.length < 512 && c === e && i.charAt(0) === "<" && !bt.test(i) && (p.support.checkClone || !bw.test(i)) && (p.support.html5Clone || !bu.test(i)) && (g = !0, f = p.fragments[i], h = f !== b), f || (f = c.createDocumentFragment(), p.clean(a, c, f, d), g && (p.fragments[i] = h && f)), { fragment: f, cacheable: g} }, p.fragments = {}, p.each({ appendTo: "append", prependTo: "prepend", insertBefore: "before", insertAfter: "after", replaceAll: "replaceWith" }, function (a, b) { p.fn[a] = function (c) { var d, e = 0, f = [], g = p(c), h = g.length, i = this.length === 1 && this[0].parentNode; if ((i == null || i && i.nodeType === 11 && i.childNodes.length === 1) && h === 1) return g[b](this[0]), this; for (; e < h; e++) d = (e > 0 ? this.clone(!0) : this).get(), p(g[e])[b](d), f = f.concat(d); return this.pushStack(f, a, g.selector) } }), p.extend({ clone: function (a, b, c) { var d, e, f, g; p.support.html5Clone || p.isXMLDoc(a) || !bu.test("<" + a.nodeName + ">") ? g = a.cloneNode(!0) : (bB.innerHTML = a.outerHTML, bB.removeChild(g = bB.firstChild)); if ((!p.support.noCloneEvent || !p.support.noCloneChecked) && (a.nodeType === 1 || a.nodeType === 11) && !p.isXMLDoc(a)) { bE(a, g), d = bF(a), e = bF(g); for (f = 0; d[f]; ++f) e[f] && bE(d[f], e[f]) } if (b) { bD(a, g); if (c) { d = bF(a), e = bF(g); for (f = 0; d[f]; ++f) bD(d[f], e[f]) } } return d = e = null, g }, clean: function (a, b, c, d) { var f, g, h, i, j, k, l, m, n, o, q, r, s = b === e && bA, t = []; if (!b || typeof b.createDocumentFragment == "undefined") b = e; for (f = 0; (h = a[f]) != null; f++) { typeof h == "number" && (h += ""); if (!h) continue; if (typeof h == "string") if (!br.test(h)) h = b.createTextNode(h); else { s = s || bk(b), l = b.createElement("div"), s.appendChild(l), h = h.replace(bo, "<$1></$2>"), i = (bp.exec(h) || ["", ""])[1].toLowerCase(), j = bz[i] || bz._default, k = j[0], l.innerHTML = j[1] + h + j[2]; while (k--) l = l.lastChild; if (!p.support.tbody) { m = bq.test(h), n = i === "table" && !m ? l.firstChild && l.firstChild.childNodes : j[1] === "<table>" && !m ? l.childNodes : []; for (g = n.length - 1; g >= 0; --g) p.nodeName(n[g], "tbody") && !n[g].childNodes.length && n[g].parentNode.removeChild(n[g]) } !p.support.leadingWhitespace && bn.test(h) && l.insertBefore(b.createTextNode(bn.exec(h)[0]), l.firstChild), h = l.childNodes, l.parentNode.removeChild(l) } h.nodeType ? t.push(h) : p.merge(t, h) } l && (h = l = s = null); if (!p.support.appendChecked) for (f = 0; (h = t[f]) != null; f++) p.nodeName(h, "input") ? bG(h) : typeof h.getElementsByTagName != "undefined" && p.grep(h.getElementsByTagName("input"), bG); if (c) { q = function (a) { if (!a.type || bx.test(a.type)) return d ? d.push(a.parentNode ? a.parentNode.removeChild(a) : a) : c.appendChild(a) }; for (f = 0; (h = t[f]) != null; f++) if (!p.nodeName(h, "script") || !q(h)) c.appendChild(h), typeof h.getElementsByTagName != "undefined" && (r = p.grep(p.merge([], h.getElementsByTagName("script")), q), t.splice.apply(t, [f + 1, 0].concat(r)), f += r.length) } return t }, cleanData: function (a, b) { var c, d, e, f, g = 0, h = p.expando, i = p.cache, j = p.support.deleteExpando, k = p.event.special; for (; (e = a[g]) != null; g++) if (b || p.acceptData(e)) { d = e[h], c = d && i[d]; if (c) { if (c.events) for (f in c.events) k[f] ? p.event.remove(e, f) : p.removeEvent(e, f, c.handle); i[d] && (delete i[d], j ? delete e[h] : e.removeAttribute ? e.removeAttribute(h) : e[h] = null, p.deletedIds.push(d)) } } } }), function () { var a, b; p.uaMatch = function (a) { a = a.toLowerCase(); var b = /(chrome)[ \/]([\w.]+)/.exec(a) || /(webkit)[ \/]([\w.]+)/.exec(a) || /(opera)(?:.*version|)[ \/]([\w.]+)/.exec(a) || /(msie) ([\w.]+)/.exec(a) || a.indexOf("compatible") < 0 && /(mozilla)(?:.*? rv:([\w.]+)|)/.exec(a) || []; return { browser: b[1] || "", version: b[2] || "0"} }, a = p.uaMatch(g.userAgent), b = {}, a.browser && (b[a.browser] = !0, b.version = a.version), b.chrome ? b.webkit = !0 : b.webkit && (b.safari = !0), p.browser = b, p.sub = function () { function a(b, c) { return new a.fn.init(b, c) } p.extend(!0, a, this), a.superclass = this, a.fn = a.prototype = this(), a.fn.constructor = a, a.sub = this.sub, a.fn.init = function c(c, d) { return d && d instanceof p && !(d instanceof a) && (d = a(d)), p.fn.init.call(this, c, d, b) }, a.fn.init.prototype = a.fn; var b = a(e); return a } } (); var bH, bI, bJ, bK = /alpha\([^)]*\)/i, bL = /opacity=([^)]*)/, bM = /^(top|right|bottom|left)$/, bN = /^(none|table(?!-c[ea]).+)/, bO = /^margin/, bP = new RegExp("^(" + q + ")(.*)$", "i"), bQ = new RegExp("^(" + q + ")(?!px)[a-z%]+$", "i"), bR = new RegExp("^([-+])=(" + q + ")", "i"), bS = {}, bT = { position: "absolute", visibility: "hidden", display: "block" }, bU = { letterSpacing: 0, fontWeight: 400 }, bV = ["Top", "Right", "Bottom", "Left"], bW = ["Webkit", "O", "Moz", "ms"], bX = p.fn.toggle; p.fn.extend({ css: function (a, c) { return p.access(this, function (a, c, d) { return d !== b ? p.style(a, c, d) : p.css(a, c) }, a, c, arguments.length > 1) }, show: function () { return b$(this, !0) }, hide: function () { return b$(this) }, toggle: function (a, b) { var c = typeof a == "boolean"; return p.isFunction(a) && p.isFunction(b) ? bX.apply(this, arguments) : this.each(function () { (c ? a : bZ(this)) ? p(this).show() : p(this).hide() }) } }), p.extend({ cssHooks: { opacity: { get: function (a, b) { if (b) { var c = bH(a, "opacity"); return c === "" ? "1" : c } } } }, cssNumber: { fillOpacity: !0, fontWeight: !0, lineHeight: !0, opacity: !0, orphans: !0, widows: !0, zIndex: !0, zoom: !0 }, cssProps: { "float": p.support.cssFloat ? "cssFloat" : "styleFloat" }, style: function (a, c, d, e) { if (!a || a.nodeType === 3 || a.nodeType === 8 || !a.style) return; var f, g, h, i = p.camelCase(c), j = a.style; c = p.cssProps[i] || (p.cssProps[i] = bY(j, i)), h = p.cssHooks[c] || p.cssHooks[i]; if (d === b) return h && "get" in h && (f = h.get(a, !1, e)) !== b ? f : j[c]; g = typeof d, g === "string" && (f = bR.exec(d)) && (d = (f[1] + 1) * f[2] + parseFloat(p.css(a, c)), g = "number"); if (d == null || g === "number" && isNaN(d)) return; g === "number" && !p.cssNumber[i] && (d += "px"); if (!h || !("set" in h) || (d = h.set(a, d, e)) !== b) try { j[c] = d } catch (k) { } }, css: function (a, c, d, e) { var f, g, h, i = p.camelCase(c); return c = p.cssProps[i] || (p.cssProps[i] = bY(a.style, i)), h = p.cssHooks[c] || p.cssHooks[i], h && "get" in h && (f = h.get(a, !0, e)), f === b && (f = bH(a, c)), f === "normal" && c in bU && (f = bU[c]), d || e !== b ? (g = parseFloat(f), d || p.isNumeric(g) ? g || 0 : f) : f }, swap: function (a, b, c) { var d, e, f = {}; for (e in b) f[e] = a.style[e], a.style[e] = b[e]; d = c.call(a); for (e in b) a.style[e] = f[e]; return d } }), a.getComputedStyle ? bH = function (b, c) { var d, e, f, g, h = a.getComputedStyle(b, null), i = b.style; return h && (d = h[c], d === "" && !p.contains(b.ownerDocument, b) && (d = p.style(b, c)), bQ.test(d) && bO.test(c) && (e = i.width, f = i.minWidth, g = i.maxWidth, i.minWidth = i.maxWidth = i.width = d, d = h.width, i.width = e, i.minWidth = f, i.maxWidth = g)), d } : e.documentElement.currentStyle && (bH = function (a, b) { var c, d, e = a.currentStyle && a.currentStyle[b], f = a.style; return e == null && f && f[b] && (e = f[b]), bQ.test(e) && !bM.test(b) && (c = f.left, d = a.runtimeStyle && a.runtimeStyle.left, d && (a.runtimeStyle.left = a.currentStyle.left), f.left = b === "fontSize" ? "1em" : e, e = f.pixelLeft + "px", f.left = c, d && (a.runtimeStyle.left = d)), e === "" ? "auto" : e }), p.each(["height", "width"], function (a, b) { p.cssHooks[b] = { get: function (a, c, d) { if (c) return a.offsetWidth === 0 && bN.test(bH(a, "display")) ? p.swap(a, bT, function () { return cb(a, b, d) }) : cb(a, b, d) }, set: function (a, c, d) { return b_(a, c, d ? ca(a, b, d, p.support.boxSizing && p.css(a, "boxSizing") === "border-box") : 0) } } }), p.support.opacity || (p.cssHooks.opacity = { get: function (a, b) { return bL.test((b && a.currentStyle ? a.currentStyle.filter : a.style.filter) || "") ? .01 * parseFloat(RegExp.$1) + "" : b ? "1" : "" }, set: function (a, b) { var c = a.style, d = a.currentStyle, e = p.isNumeric(b) ? "alpha(opacity=" + b * 100 + ")" : "", f = d && d.filter || c.filter || ""; c.zoom = 1; if (b >= 1 && p.trim(f.replace(bK, "")) === "" && c.removeAttribute) { c.removeAttribute("filter"); if (d && !d.filter) return } c.filter = bK.test(f) ? f.replace(bK, e) : f + " " + e } }), p(function () { p.support.reliableMarginRight || (p.cssHooks.marginRight = { get: function (a, b) { return p.swap(a, { display: "inline-block" }, function () { if (b) return bH(a, "marginRight") }) } }), !p.support.pixelPosition && p.fn.position && p.each(["top", "left"], function (a, b) { p.cssHooks[b] = { get: function (a, c) { if (c) { var d = bH(a, b); return bQ.test(d) ? p(a).position()[b] + "px" : d } } } }) }), p.expr && p.expr.filters && (p.expr.filters.hidden = function (a) { return a.offsetWidth === 0 && a.offsetHeight === 0 || !p.support.reliableHiddenOffsets && (a.style && a.style.display || bH(a, "display")) === "none" }, p.expr.filters.visible = function (a) { return !p.expr.filters.hidden(a) }), p.each({ margin: "", padding: "", border: "Width" }, function (a, b) { p.cssHooks[a + b] = { expand: function (c) { var d, e = typeof c == "string" ? c.split(" ") : [c], f = {}; for (d = 0; d < 4; d++) f[a + bV[d] + b] = e[d] || e[d - 2] || e[0]; return f } }, bO.test(a) || (p.cssHooks[a + b].set = b_) }); var cd = /%20/g, ce = /\[\]$/, cf = /\r?\n/g, cg = /^(?:color|date|datetime|datetime-local|email|hidden|month|number|password|range|search|tel|text|time|url|week)$/i, ch = /^(?:select|textarea)/i; p.fn.extend({ serialize: function () { return p.param(this.serializeArray()) }, serializeArray: function () { return this.map(function () { return this.elements ? p.makeArray(this.elements) : this }).filter(function () { return this.name && !this.disabled && (this.checked || ch.test(this.nodeName) || cg.test(this.type)) }).map(function (a, b) { var c = p(this).val(); return c == null ? null : p.isArray(c) ? p.map(c, function (a, c) { return { name: b.name, value: a.replace(cf, "\r\n")} }) : { name: b.name, value: c.replace(cf, "\r\n")} }).get() } }), p.param = function (a, c) { var d, e = [], f = function (a, b) { b = p.isFunction(b) ? b() : b == null ? "" : b, e[e.length] = encodeURIComponent(a) + "=" + encodeURIComponent(b) }; c === b && (c = p.ajaxSettings && p.ajaxSettings.traditional); if (p.isArray(a) || a.jquery && !p.isPlainObject(a)) p.each(a, function () { f(this.name, this.value) }); else for (d in a) ci(d, a[d], c, f); return e.join("&").replace(cd, "+") }; var cj, ck, cl = /#.*$/, cm = /^(.*?):[ \t]*([^\r\n]*)\r?$/mg, cn = /^(?:about|app|app\-storage|.+\-extension|file|res|widget):$/, co = /^(?:GET|HEAD)$/, cp = /^\/\//, cq = /\?/, cr = /<script\b[^<]*(?:(?!<\/script>)<[^<]*)*<\/script>/gi, cs = /([?&])_=[^&]*/, ct = /^([\w\+\.\-]+:)(?:\/\/([^\/?#:]*)(?::(\d+)|)|)/, cu = p.fn.load, cv = {}, cw = {}, cx = ["*/"] + ["*"]; try { ck = f.href } catch (cy) { ck = e.createElement("a"), ck.href = "", ck = ck.href } cj = ct.exec(ck.toLowerCase()) || [], p.fn.load = function (a, c, d) { if (typeof a != "string" && cu) return cu.apply(this, arguments); if (!this.length) return this; var e, f, g, h = this, i = a.indexOf(" "); return i >= 0 && (e = a.slice(i, a.length), a = a.slice(0, i)), p.isFunction(c) ? (d = c, c = b) : c && typeof c == "object" && (f = "POST"), p.ajax({ url: a, type: f, dataType: "html", data: c, complete: function (a, b) { d && h.each(d, g || [a.responseText, b, a]) } }).done(function (a) { g = arguments, h.html(e ? p("<div>").append(a.replace(cr, "")).find(e) : a) }), this }, p.each("ajaxStart ajaxStop ajaxComplete ajaxError ajaxSuccess ajaxSend".split(" "), function (a, b) { p.fn[b] = function (a) { return this.on(b, a) } }), p.each(["get", "post"], function (a, c) { p[c] = function (a, d, e, f) { return p.isFunction(d) && (f = f || e, e = d, d = b), p.ajax({ type: c, url: a, data: d, success: e, dataType: f }) } }), p.extend({ getScript: function (a, c) { return p.get(a, b, c, "script") }, getJSON: function (a, b, c) { return p.get(a, b, c, "json") }, ajaxSetup: function (a, b) { return b ? cB(a, p.ajaxSettings) : (b = a, a = p.ajaxSettings), cB(a, b), a }, ajaxSettings: { url: ck, isLocal: cn.test(cj[1]), global: !0, type: "GET", contentType: "application/x-www-form-urlencoded; charset=UTF-8", processData: !0, async: !0, accepts: { xml: "application/xml, text/xml", html: "text/html", text: "text/plain", json: "application/json, text/javascript", "*": cx }, contents: { xml: /xml/, html: /html/, json: /json/ }, responseFields: { xml: "responseXML", text: "responseText" }, converters: { "* text": a.String, "text html": !0, "text json": p.parseJSON, "text xml": p.parseXML }, flatOptions: { context: !0, url: !0} }, ajaxPrefilter: cz(cv), ajaxTransport: cz(cw), ajax: function (a, c) { function y(a, c, f, i) { var k, s, t, u, w, y = c; if (v === 2) return; v = 2, h && clearTimeout(h), g = b, e = i || "", x.readyState = a > 0 ? 4 : 0, f && (u = cC(l, x, f)); if (a >= 200 && a < 300 || a === 304) l.ifModified && (w = x.getResponseHeader("Last-Modified"), w && (p.lastModified[d] = w), w = x.getResponseHeader("Etag"), w && (p.etag[d] = w)), a === 304 ? (y = "notmodified", k = !0) : (k = cD(l, u), y = k.state, s = k.data, t = k.error, k = !t); else { t = y; if (!y || a) y = "error", a < 0 && (a = 0) } x.status = a, x.statusText = (c || y) + "", k ? o.resolveWith(m, [s, y, x]) : o.rejectWith(m, [x, y, t]), x.statusCode(r), r = b, j && n.trigger("ajax" + (k ? "Success" : "Error"), [x, l, k ? s : t]), q.fireWith(m, [x, y]), j && (n.trigger("ajaxComplete", [x, l]), --p.active || p.event.trigger("ajaxStop")) } typeof a == "object" && (c = a, a = b), c = c || {}; var d, e, f, g, h, i, j, k, l = p.ajaxSetup({}, c), m = l.context || l, n = m !== l && (m.nodeType || m instanceof p) ? p(m) : p.event, o = p.Deferred(), q = p.Callbacks("once memory"), r = l.statusCode || {}, t = {}, u = {}, v = 0, w = "canceled", x = { readyState: 0, setRequestHeader: function (a, b) { if (!v) { var c = a.toLowerCase(); a = u[c] = u[c] || a, t[a] = b } return this }, getAllResponseHeaders: function () { return v === 2 ? e : null }, getResponseHeader: function (a) { var c; if (v === 2) { if (!f) { f = {}; while (c = cm.exec(e)) f[c[1].toLowerCase()] = c[2] } c = f[a.toLowerCase()] } return c === b ? null : c }, overrideMimeType: function (a) { return v || (l.mimeType = a), this }, abort: function (a) { return a = a || w, g && g.abort(a), y(0, a), this } }; o.promise(x), x.success = x.done, x.error = x.fail, x.complete = q.add, x.statusCode = function (a) { if (a) { var b; if (v < 2) for (b in a) r[b] = [r[b], a[b]]; else b = a[x.status], x.always(b) } return this }, l.url = ((a || l.url) + "").replace(cl, "").replace(cp, cj[1] + "//"), l.dataTypes = p.trim(l.dataType || "*").toLowerCase().split(s), l.crossDomain == null && (i = ct.exec(l.url.toLowerCase()) || !1, l.crossDomain = i && i.join(":") + (i[3] ? "" : i[1] === "http:" ? 80 : 443) !== cj.join(":") + (cj[3] ? "" : cj[1] === "http:" ? 80 : 443)), l.data && l.processData && typeof l.data != "string" && (l.data = p.param(l.data, l.traditional)), cA(cv, l, c, x); if (v === 2) return x; j = l.global, l.type = l.type.toUpperCase(), l.hasContent = !co.test(l.type), j && p.active++ === 0 && p.event.trigger("ajaxStart"); if (!l.hasContent) { l.data && (l.url += (cq.test(l.url) ? "&" : "?") + l.data, delete l.data), d = l.url; if (l.cache === !1) { var z = p.now(), A = l.url.replace(cs, "$1_=" + z); l.url = A + (A === l.url ? (cq.test(l.url) ? "&" : "?") + "_=" + z : "") } } (l.data && l.hasContent && l.contentType !== !1 || c.contentType) && x.setRequestHeader("Content-Type", l.contentType), l.ifModified && (d = d || l.url, p.lastModified[d] && x.setRequestHeader("If-Modified-Since", p.lastModified[d]), p.etag[d] && x.setRequestHeader("If-None-Match", p.etag[d])), x.setRequestHeader("Accept", l.dataTypes[0] && l.accepts[l.dataTypes[0]] ? l.accepts[l.dataTypes[0]] + (l.dataTypes[0] !== "*" ? ", " + cx + "; q=0.01" : "") : l.accepts["*"]); for (k in l.headers) x.setRequestHeader(k, l.headers[k]); if (!l.beforeSend || l.beforeSend.call(m, x, l) !== !1 && v !== 2) { w = "abort"; for (k in { success: 1, error: 1, complete: 1 }) x[k](l[k]); g = cA(cw, l, c, x); if (!g) y(-1, "No Transport"); else { x.readyState = 1, j && n.trigger("ajaxSend", [x, l]), l.async && l.timeout > 0 && (h = setTimeout(function () { x.abort("timeout") }, l.timeout)); try { v = 1, g.send(t, y) } catch (B) { if (v < 2) y(-1, B); else throw B } } return x } return x.abort() }, active: 0, lastModified: {}, etag: {} }); var cE = [], cF = /\?/, cG = /(=)\?(?=&|$)|\?\?/, cH = p.now(); p.ajaxSetup({ jsonp: "callback", jsonpCallback: function () { var a = cE.pop() || p.expando + "_" + cH++; return this[a] = !0, a } }), p.ajaxPrefilter("json jsonp", function (c, d, e) { var f, g, h, i = c.data, j = c.url, k = c.jsonp !== !1, l = k && cG.test(j), m = k && !l && typeof i == "string" && !(c.contentType || "").indexOf("application/x-www-form-urlencoded") && cG.test(i); if (c.dataTypes[0] === "jsonp" || l || m) return f = c.jsonpCallback = p.isFunction(c.jsonpCallback) ? c.jsonpCallback() : c.jsonpCallback, g = a[f], l ? c.url = j.replace(cG, "$1" + f) : m ? c.data = i.replace(cG, "$1" + f) : k && (c.url += (cF.test(j) ? "&" : "?") + c.jsonp + "=" + f), c.converters["script json"] = function () { return h || p.error(f + " was not called"), h[0] }, c.dataTypes[0] = "json", a[f] = function () { h = arguments }, e.always(function () { a[f] = g, c[f] && (c.jsonpCallback = d.jsonpCallback, cE.push(f)), h && p.isFunction(g) && g(h[0]), h = g = b }), "script" }), p.ajaxSetup({ accepts: { script: "text/javascript, application/javascript, application/ecmascript, application/x-ecmascript" }, contents: { script: /javascript|ecmascript/ }, converters: { "text script": function (a) { return p.globalEval(a), a } } }), p.ajaxPrefilter("script", function (a) { a.cache === b && (a.cache = !1), a.crossDomain && (a.type = "GET", a.global = !1) }), p.ajaxTransport("script", function (a) { if (a.crossDomain) { var c, d = e.head || e.getElementsByTagName("head")[0] || e.documentElement; return { send: function (f, g) { c = e.createElement("script"), c.async = "async", a.scriptCharset && (c.charset = a.scriptCharset), c.src = a.url, c.onload = c.onreadystatechange = function (a, e) { if (e || !c.readyState || /loaded|complete/.test(c.readyState)) c.onload = c.onreadystatechange = null, d && c.parentNode && d.removeChild(c), c = b, e || g(200, "success") }, d.insertBefore(c, d.firstChild) }, abort: function () { c && c.onload(0, 1) } } } }); var cI, cJ = a.ActiveXObject ? function () { for (var a in cI) cI[a](0, 1) } : !1, cK = 0; p.ajaxSettings.xhr = a.ActiveXObject ? function () { return !this.isLocal && cL() || cM() } : cL, function (a) { p.extend(p.support, { ajax: !!a, cors: !!a && "withCredentials" in a }) } (p.ajaxSettings.xhr()), p.support.ajax && p.ajaxTransport(function (c) { if (!c.crossDomain || p.support.cors) { var d; return { send: function (e, f) { var g, h, i = c.xhr(); c.username ? i.open(c.type, c.url, c.async, c.username, c.password) : i.open(c.type, c.url, c.async); if (c.xhrFields) for (h in c.xhrFields) i[h] = c.xhrFields[h]; c.mimeType && i.overrideMimeType && i.overrideMimeType(c.mimeType), !c.crossDomain && !e["X-Requested-With"] && (e["X-Requested-With"] = "XMLHttpRequest"); try { for (h in e) i.setRequestHeader(h, e[h]) } catch (j) { } i.send(c.hasContent && c.data || null), d = function (a, e) { var h, j, k, l, m; try { if (d && (e || i.readyState === 4)) { d = b, g && (i.onreadystatechange = p.noop, cJ && delete cI[g]); if (e) i.readyState !== 4 && i.abort(); else { h = i.status, k = i.getAllResponseHeaders(), l = {}, m = i.responseXML, m && m.documentElement && (l.xml = m); try { l.text = i.responseText } catch (a) { } try { j = i.statusText } catch (n) { j = "" } !h && c.isLocal && !c.crossDomain ? h = l.text ? 200 : 404 : h === 1223 && (h = 204) } } } catch (o) { e || f(-1, o) } l && f(h, j, l, k) }, c.async ? i.readyState === 4 ? setTimeout(d, 0) : (g = ++cK, cJ && (cI || (cI = {}, p(a).unload(cJ)), cI[g] = d), i.onreadystatechange = d) : d() }, abort: function () { d && d(0, 1) } } } }); var cN, cO, cP = /^(?:toggle|show|hide)$/, cQ = new RegExp("^(?:([-+])=|)(" + q + ")([a-z%]*)$", "i"), cR = /queueHooks$/, cS = [cY], cT = { "*": [function (a, b) { var c, d, e = this.createTween(a, b), f = cQ.exec(b), g = e.cur(), h = +g || 0, i = 1, j = 20; if (f) { c = +f[2], d = f[3] || (p.cssNumber[a] ? "" : "px"); if (d !== "px" && h) { h = p.css(e.elem, a, !0) || c || 1; do i = i || ".5", h = h / i, p.style(e.elem, a, h + d); while (i !== (i = e.cur() / g) && i !== 1 && --j) } e.unit = d, e.start = h, e.end = f[1] ? h + (f[1] + 1) * c : c } return e } ] }; p.Animation = p.extend(cW, { tweener: function (a, b) { p.isFunction(a) ? (b = a, a = ["*"]) : a = a.split(" "); var c, d = 0, e = a.length; for (; d < e; d++) c = a[d], cT[c] = cT[c] || [], cT[c].unshift(b) }, prefilter: function (a, b) { b ? cS.unshift(a) : cS.push(a) } }), p.Tween = cZ, cZ.prototype = { constructor: cZ, init: function (a, b, c, d, e, f) { this.elem = a, this.prop = c, this.easing = e || "swing", this.options = b, this.start = this.now = this.cur(), this.end = d, this.unit = f || (p.cssNumber[c] ? "" : "px") }, cur: function () { var a = cZ.propHooks[this.prop]; return a && a.get ? a.get(this) : cZ.propHooks._default.get(this) }, run: function (a) { var b, c = cZ.propHooks[this.prop]; return this.options.duration ? this.pos = b = p.easing[this.easing](a, this.options.duration * a, 0, 1, this.options.duration) : this.pos = b = a, this.now = (this.end - this.start) * b + this.start, this.options.step && this.options.step.call(this.elem, this.now, this), c && c.set ? c.set(this) : cZ.propHooks._default.set(this), this } }, cZ.prototype.init.prototype = cZ.prototype, cZ.propHooks = { _default: { get: function (a) { var b; return a.elem[a.prop] == null || !!a.elem.style && a.elem.style[a.prop] != null ? (b = p.css(a.elem, a.prop, !1, ""), !b || b === "auto" ? 0 : b) : a.elem[a.prop] }, set: function (a) { p.fx.step[a.prop] ? p.fx.step[a.prop](a) : a.elem.style && (a.elem.style[p.cssProps[a.prop]] != null || p.cssHooks[a.prop]) ? p.style(a.elem, a.prop, a.now + a.unit) : a.elem[a.prop] = a.now } } }, cZ.propHooks.scrollTop = cZ.propHooks.scrollLeft = { set: function (a) { a.elem.nodeType && a.elem.parentNode && (a.elem[a.prop] = a.now) } }, p.each(["toggle", "show", "hide"], function (a, b) { var c = p.fn[b]; p.fn[b] = function (d, e, f) { return d == null || typeof d == "boolean" || !a && p.isFunction(d) && p.isFunction(e) ? c.apply(this, arguments) : this.animate(c$(b, !0), d, e, f) } }), p.fn.extend({ fadeTo: function (a, b, c, d) { return this.filter(bZ).css("opacity", 0).show().end().animate({ opacity: b }, a, c, d) }, animate: function (a, b, c, d) { var e = p.isEmptyObject(a), f = p.speed(b, c, d), g = function () { var b = cW(this, p.extend({}, a), f); e && b.stop(!0) }; return e || f.queue === !1 ? this.each(g) : this.queue(f.queue, g) }, stop: function (a, c, d) { var e = function (a) { var b = a.stop; delete a.stop, b(d) }; return typeof a != "string" && (d = c, c = a, a = b), c && a !== !1 && this.queue(a || "fx", []), this.each(function () { var b = !0, c = a != null && a + "queueHooks", f = p.timers, g = p._data(this); if (c) g[c] && g[c].stop && e(g[c]); else for (c in g) g[c] && g[c].stop && cR.test(c) && e(g[c]); for (c = f.length; c--; ) f[c].elem === this && (a == null || f[c].queue === a) && (f[c].anim.stop(d), b = !1, f.splice(c, 1)); (b || !d) && p.dequeue(this, a) }) } }), p.each({ slideDown: c$("show"), slideUp: c$("hide"), slideToggle: c$("toggle"), fadeIn: { opacity: "show" }, fadeOut: { opacity: "hide" }, fadeToggle: { opacity: "toggle"} }, function (a, b) { p.fn[a] = function (a, c, d) { return this.animate(b, a, c, d) } }), p.speed = function (a, b, c) { var d = a && typeof a == "object" ? p.extend({}, a) : { complete: c || !c && b || p.isFunction(a) && a, duration: a, easing: c && b || b && !p.isFunction(b) && b }; d.duration = p.fx.off ? 0 : typeof d.duration == "number" ? d.duration : d.duration in p.fx.speeds ? p.fx.speeds[d.duration] : p.fx.speeds._default; if (d.queue == null || d.queue === !0) d.queue = "fx"; return d.old = d.complete, d.complete = function () { p.isFunction(d.old) && d.old.call(this), d.queue && p.dequeue(this, d.queue) }, d }, p.easing = { linear: function (a) { return a }, swing: function (a) { return .5 - Math.cos(a * Math.PI) / 2 } }, p.timers = [], p.fx = cZ.prototype.init, p.fx.tick = function () { var a, b = p.timers, c = 0; for (; c < b.length; c++) a = b[c], !a() && b[c] === a && b.splice(c--, 1); b.length || p.fx.stop() }, p.fx.timer = function (a) { a() && p.timers.push(a) && !cO && (cO = setInterval(p.fx.tick, p.fx.interval)) }, p.fx.interval = 13, p.fx.stop = function () { clearInterval(cO), cO = null }, p.fx.speeds = { slow: 600, fast: 200, _default: 400 }, p.fx.step = {}, p.expr && p.expr.filters && (p.expr.filters.animated = function (a) { return p.grep(p.timers, function (b) { return a === b.elem }).length }); var c_ = /^(?:body|html)$/i; p.fn.offset = function (a) { if (arguments.length) return a === b ? this : this.each(function (b) { p.offset.setOffset(this, a, b) }); var c, d, e, f, g, h, i, j = { top: 0, left: 0 }, k = this[0], l = k && k.ownerDocument; if (!l) return; return (d = l.body) === k ? p.offset.bodyOffset(k) : (c = l.documentElement, p.contains(c, k) ? (typeof k.getBoundingClientRect != "undefined" && (j = k.getBoundingClientRect()), e = da(l), f = c.clientTop || d.clientTop || 0, g = c.clientLeft || d.clientLeft || 0, h = e.pageYOffset || c.scrollTop, i = e.pageXOffset || c.scrollLeft, { top: j.top + h - f, left: j.left + i - g }) : j) }, p.offset = { bodyOffset: function (a) { var b = a.offsetTop, c = a.offsetLeft; return p.support.doesNotIncludeMarginInBodyOffset && (b += parseFloat(p.css(a, "marginTop")) || 0, c += parseFloat(p.css(a, "marginLeft")) || 0), { top: b, left: c} }, setOffset: function (a, b, c) { var d = p.css(a, "position"); d === "static" && (a.style.position = "relative"); var e = p(a), f = e.offset(), g = p.css(a, "top"), h = p.css(a, "left"), i = (d === "absolute" || d === "fixed") && p.inArray("auto", [g, h]) > -1, j = {}, k = {}, l, m; i ? (k = e.position(), l = k.top, m = k.left) : (l = parseFloat(g) || 0, m = parseFloat(h) || 0), p.isFunction(b) && (b = b.call(a, c, f)), b.top != null && (j.top = b.top - f.top + l), b.left != null && (j.left = b.left - f.left + m), "using" in b ? b.using.call(a, j) : e.css(j) } }, p.fn.extend({ position: function () { if (!this[0]) return; var a = this[0], b = this.offsetParent(), c = this.offset(), d = c_.test(b[0].nodeName) ? { top: 0, left: 0} : b.offset(); return c.top -= parseFloat(p.css(a, "marginTop")) || 0, c.left -= parseFloat(p.css(a, "marginLeft")) || 0, d.top += parseFloat(p.css(b[0], "borderTopWidth")) || 0, d.left += parseFloat(p.css(b[0], "borderLeftWidth")) || 0, { top: c.top - d.top, left: c.left - d.left} }, offsetParent: function () { return this.map(function () { var a = this.offsetParent || e.body; while (a && !c_.test(a.nodeName) && p.css(a, "position") === "static") a = a.offsetParent; return a || e.body }) } }), p.each({ scrollLeft: "pageXOffset", scrollTop: "pageYOffset" }, function (a, c) { var d = /Y/.test(c); p.fn[a] = function (e) { return p.access(this, function (a, e, f) { var g = da(a); if (f === b) return g ? c in g ? g[c] : g.document.documentElement[e] : a[e]; g ? g.scrollTo(d ? p(g).scrollLeft() : f, d ? f : p(g).scrollTop()) : a[e] = f }, a, e, arguments.length, null) } }), p.each({ Height: "height", Width: "width" }, function (a, c) { p.each({ padding: "inner" + a, content: c, "": "outer" + a }, function (d, e) { p.fn[e] = function (e, f) { var g = arguments.length && (d || typeof e != "boolean"), h = d || (e === !0 || f === !0 ? "margin" : "border"); return p.access(this, function (c, d, e) { var f; return p.isWindow(c) ? c.document.documentElement["client" + a] : c.nodeType === 9 ? (f = c.documentElement, Math.max(c.body["scroll" + a], f["scroll" + a], c.body["offset" + a], f["offset" + a], f["client" + a])) : e === b ? p.css(c, d, e, h) : p.style(c, d, e, h) }, c, g ? e : b, g, null) } }) }), a.jQuery = a.$ = p, typeof define == "function" && define.amd && define.amd.jQuery && define("jquery", [], function () { return p }) })(window);
function getElementsByClassName(className, tag, elm) {
    var testClass = new RegExp("(^|\\s)" + className + "(\\s|$)");
    var tag = tag || "*";
    var elm = elm || document;
    var elements = (tag == "*" && elm.all) ? elm.all : elm.getElementsByTagName(tag);
    var returnElements = [];
    var current;
    var length = elements.length;
    for (var i = 0; i < length; i++) {
        current = elements[i];
        if (testClass.test(current.className)) {
            returnElements.push(current);
        }
    }
    return returnElements;
}

function getDate(dt, format) {

    var dd = dt.getDate();
    var mm = dt.getMonth();
    mm = mm + 1;
    var yy = dt.getFullYear();
    var returndate = "";

    if (format == "dd/mm/yyyy") {
        returndate = dd + "/" + mm + "/" + yy;
    }
    if (format == "mm/dd/yyyy") {
        returndate = mm + "/" + dd + "/" + yy;
    }

    return returndate;
}

function IsTime(obj) {
    //alert(this.event.keyCode);
    //alert(this.event.keyCode.char);
    if ((this.event.keyCode >= 48 && this.event.keyCode <= 57) || (this.event.keyCode >= 96 && this.event.keyCode <= 105) || this.event.keyCode == 46 || this.event.keyCode == 8 || this.event.keyCode == 9 || this.event.keyCode == 37 || this.event.keyCode == 39) {
    }
    else {
        this.event.returnValue = false;
    }
    if ((this.event.keyCode != 46) && (this.event.keyCode != 8)) {
        if (obj.value.length == 2)
            obj.value += ":";
        //if (obj.value.length==5)
        //obj.value+=":";   
    }
}

function TypeDate(e, obj) {
    //alert(this.event.keyCode);
    //alert(this.event.keyCode.char);
    var code = (e.keyCode) ? e.keyCode : e.which;
    //alert(code);
    if ((code >= 48 && code <= 57) || (code >= 96 && code <= 105) || code == 46 || code == 8 || code == 9 || code == 37 || code == 39) {
    }
    else {
        //this.event.returnValue = false;
        if (e.which) {
            e.preventDefault();
        }
        else {
            e.returnValue = false;
        }
    }
    if (obj.value.length >= 10) {
        if (code != 8 && code != 9 && code != 37 && code != 39 && code != 46) {
            if (e.which) {
                e.preventDefault();
            }
            else {
                e.returnValue = false;
            }
        }
    }
    if (code == 111 || code == 191) {
        if (obj.value.length == 1) {
            obj.value = '0' + obj.value.toString();
        }
        if (obj.value.length == 4) {
            obj.value = obj.value.substr(0, 3) + '0' + obj.value.substr(3, 1);
        }
    }
    if ((code != 46) && (code != 8)) {
        if (obj.value.length == 2 || obj.value.length == 5)
            obj.value += "/";
    }
}

function setPopup(selector) {
    $(selector).dialog({
        bgiframe: true,
        autoOpen: false,
        height: 300,
        modal: true
        , buttons: {

            Cancel: function () {
                $(this).dialog('close');
            },
            Select: function () {
                $(this).dialog('close');
            }
        }
        //        },
        //        close: function () {
        //            allFields.val('').removeClass('ui-state-error');
        //        }
    });
}

function copyCon(DataDiv, DataGrid, HeaderDiv) {
    var HeaderTable = "tbl" + HeaderDiv;
    DataDiv = "#" + DataDiv;
    DataGrid = "#" + DataGrid;
    HeaderDiv = "#" + HeaderDiv;

    var DataGridHeader = DataGrid + "_RowHeader";
    var tblWidth = $(DataGrid).width() + "px";
    $(HeaderDiv).html("<table id='" + HeaderTable + "' border='1' class='KGrid' style='width: " + tblWidth + "' ></table>");
    $(DataGridHeader).clone().appendTo("#" + HeaderTable);

    var tbRow = $(DataGrid + " tr").eq(1).attr("id");
    var idx = 0;
    $("#" + tbRow + " td").each(function () {
        $("#" + HeaderTable + " th").eq(idx).width(($(this).width() + 5) + "px");
        //$("#" + HeaderTable + " th").eq(idx).height("25px");
        $("#" + HeaderTable + " th").eq(idx).attr({ nowrap: "nowrap" });
        idx = idx + 1;
    });
    //$("#" + HeaderTable + " th").eq(idx - 1).width($("#" + HeaderTable + " th").eq(idx - 1).width() + 20 + "px");

    elem = document.getElementById($(DataDiv).attr("id"));
    if (elem.clientWidth < elem.scrollWidth)
        $("#" + HeaderTable + " tr").append("<th class='KGridHeader' nowrap='nowrap' style='width:14px;'>&nbsp;</th>");
    //alert("The element has a vertical scrollbar!"); 


    $(HeaderDiv).width(($(DataDiv).width()) + "px");
    //$("#" + HeaderTable).height("22px");
    //$(DataGridHeader).height("25px");
    $(HeaderDiv).css({
        "top": (($(DataGridHeader).offset()).top - 5) + "px", "left": (($(DataGridHeader).offset()).left) + "px",
        "overflow": "scroll", "overflow-x": "hidden", "overflow-y": "hidden", "border-bottom": "0px",
        "padding": "0px", "position": "absolute", "z-index": "0", "margin": "0px", "border-top": "0px"
    });

    //$(DataGridHeader).css({"display":"none"});
    //$(DataGridHeader).hide();
}

jQuery.fn.extend({
    msgBox: function (msg, timeout, option, type, fixed) {
        if (timeout == null || timeout == undefined || timeout == "")
            timeout = 2000;
        if (option == null || option == undefined || option == "")
            option = 'linear';
        //$(this).addClass("msgBox");
        var color = "#000";
        var backColor = "#D9E3FF";
        if (type != null && type != undefined) {
            if (type == "success") {
                color = "#107A3A";
                backColor = "#347c2c";
            }
            if (type == "error") {
                color = "#107A3A";
                backColor = "#ff0000";
            }
        }
        fixed = fixed || false;
        color = "#fff";
        //alert($(window).scrollTop());
        if (fixed == false) {
            $(this).css({ "background-color": backColor, "color": color, "position": "absolute", "top": $(window).scrollTop() + 100
            });
            $(this).addClass("clsMessage");
        }
        else {
            $(this).css({ "background-color": backColor, "color": color, "top": $(window).scrollTop() + 50
            });
            $(this).addClass("clsMessage");
        }
        msg = "<div style='width:99%;border:1px solid white'>" + msg + "</div>";
        $(this).html(msg);
        $(this).fadeIn(timeout, option, function () {
            $(this).delay(2000).fadeOut(timeout, option);
        });
    }
});


jQuery.fn.extend({
    msgBox1: function (msg, timeout, option, type, fixed) {
        if (timeout == null || timeout == undefined || timeout == "")
            timeout = 2000;
        if (option == null || option == undefined || option == "")
            option = 'linear';
        //$(this).addClass("msgBox");
        var color = "#000";
        var backColor = "#D9E3FF";
        if (type != null && type != undefined) {
            if (type == "success") {
                color = "#107A3A";
                backColor = "#347c2c";
            }
            if (type == "error") {
                color = "#107A3A";
                backColor = "#ff0000";
            }
        }
        fixed = fixed || false;
        color = "#fff";
        //alert($(window).scrollTop());
        if (fixed == false) {
            $(this).css({ "background-color": backColor, "color": color, "position": "absolute"
            });
            $(this).addClass("clsMessage");
        }
        else {
            $(this).css({ "background-color": backColor, "color": color
            });
            $(this).addClass("clsMessage");
        }
        msg = "<div style='width:99%;border:1px solid white'>" + msg + "</div>";
        $(this).html(msg);
        $(this).fadeIn(timeout, option, function () {
            $(this).delay(2000).fadeOut(timeout, option);
        });
    }
});

function DisplayMessage(msgContainer) {


    var dataValue = $("#" + msgContainer).html();
    if ($.trim(dataValue) != "") {

       // alert(dataValue);
      //  alert(dataValue.toString().toLowerCase().indexOf("div&gt;"));
        if (dataValue.toString().toLowerCase().indexOf("div&gt;") == -1) {
            var msgStr = $.trim(dataValue).split("/");
            if (msgStr[0] == 0) {
                $("#" + msgContainer).msgBox(msgStr[1], 1000, "linear", "error", false);

            }
            else {
                $("#" + msgContainer).msgBox(msgStr[1], 1000, "linear", "success", false);
            }
        }
    }
    // SearchFunctionsCall();

}
function DisplayMessageContainer(msgContainer) {


    if ($.trim($("#" + msgContainer).html()) != "") {
        var msgStr = $.trim($("#" + msgContainer).html()).split("/");
        if (msgStr[0] == 0) {
            $("#" + msgContainer).msgBox1(msgStr[1], 1000, "linear", "error", false);

        }
        else {
            $("#" + msgContainer).msgBox1(msgStr[1], 1000, "linear", "success", false);
        }
    }
    // SearchFunctionsCall();

}
function DisplayMessageClient(msgContainer, msg, status) {
    //alert(status);
    if (status == 0) {
        $("#" + msgContainer).msgBox(msg, 1000, "linear", "error", false);

    }
    else {
        $("#" + msgContainer).msgBox(msg, 1000, "linear", "success", false);
    }

}
function DisplayMessage1(msgContainer) {


    if ($.trim($("#" + msgContainer).html()) != "") {
        var msgStr = $.trim($("#" + msgContainer).html()).split("/");
        if (msgStr[0] == 0) {
            $("#" + msgContainer).msgBox(msgStr[1], 1000, "linear", "error", true);

        }
        else {
            $("#" + msgContainer).msgBox(msgStr[1], 1000, "linear", "success", true);
        }
    }
}

function loadRcptData(e, obj, dvId, setFunName, updatePanel) {
    var code = (e.keyCode) ? e.keyCode : e.which;
    if (updatePanel == null || updatePanel == undefined || updatePanel == "") {
        updatePanel = "UpdatePanel1";
    }
    if (code == 13) {
        if (e.which) {
            e.preventDefault();
        }
        else {
            e.returnValue = false;
        }

        if (obj.value == "") {
            $("#" + dvId).msgBox("Please Enter Receipt No...!!!", 1000, "linear", "error", false);
        }
        else {
            postBackPartial(event, updatePanel, setFunName);
            //__doPostBack('', setFunName);
        }
    }
    else {

        if (code > 31 && (code < 48 || code > 57))
            return false;

    }
}

function setGridHeader(id, filter, containerHeight) {

    /****************Grid Sort & Fix Starts**************************/
    // var len = ($("#grdSearch").html().indexOf("yes") >= 0) ? true : false;
    //var flag = document.getElementById('grdSearch') != null ? ((document.getElementById('grdSearch').innerHTML.indexOf("No data Available") >= 0) ? false : true) : false;
    if (filter == true || filter == null || filter == undefined) {
        filter = true;
    }
    else {
        filter = false;
    }

    if (containerHeight == null || containerHeight == undefined || containerHeight.toString() == "") {
        containerHeight = 200;
    }


    var selector = "";
    if (id == null || id == undefined || id == "") {
        selector = ".clsGrdSearch";
    }
    else {
        selector = "#" + id;
    }

    if (($(selector).html() == null) || ($(selector).html().length == 0)) {
        flag = false;
    }
    else {
        var flag = $(selector).html() != null ? (($(selector).html().indexOf("No data Available") >= 0) ? false : true) : false;
    }
    if (flag == true) {

        //        if (oTable != null && oTable != undefined) {
        //            oTable.fnClearTable();
        //        }
        var oTable = $(selector).dataTable({
            //                        "aaSorting": [[0, 'asc'], [1, 'asc']],
            //                        "aoColumnDefs": [{ "sType": 'string-case', "aTargets": [1] }],
            "sScrollY": containerHeight,
            "sScrollX": "100%",
            //"sScrollXInner": "100%",
            "bFilter": filter,
            "bInfo": filter,
            "bJQueryUI": filter,
            "bPaginate": false,
            "bSort": filter,
            //"bStateSave": true,
            //"bRetrieve":true,
            //"bDeferRender": true,
            "bProcessing": true,
            "bDestroy": true
        });
        //        setTimeout(function () {
        //            oTable.fnAdjustColumnSizing();
        //                  }, 100);
        //oTable.fnAdjustColumnSizing();
        //oTable.fnDraw();
    }
    else {
    }
    /*****************Grid Sort & Fix Ends****************************/

}

$.ctrl = function (key, callback, args) {
    var isCtrl = false;
    $(document).keydown(function (e) {
        if (!args) args = []; // IE barks when args is null

        if (e.ctrlKey) {
            isCtrl = true;
        }
        else {
            isCtrl = false;
        }
        if (e.keyCode == key.charCodeAt(0) && isCtrl) {
            callback.apply(this, args);
            return false;
        }
    }).keyup(function (e) {
        if (e.ctrlKey) isCtrl = false;
    });
};


function SetHotKeys() {
    //    $.ctrl('N', function () {
    //        $(".New").click();
    //    });
    //    $.ctrl('S', function () {
    //        $(".Save").click();
    //    });
}

(function ($) {
    $.fn.hasScrollBar = function () {
        return this.get(0).scrollHeight > this.height();
    }
})(jQuery);

var cookieJson = "";
function parseCookies() {
    var arrCookie = document.cookie.split("&");
    for (var i = 0; i < arrCookie.length; i++) {
        var key = "";
        var val = "";
        var node = arrCookie[i].toString().split("=");
        key = node[0];
        val = node[1];
        cookieJson = cookieJson + ",\"" + key + "\":" + JSON.stringify(val) + "";
        //alert(arrCookie[i]);
    }
    cookieJson = "{" + cookieJson.substr(1, cookieJson.length - 1) + "}";
    cookieJson = jQuery.parseJSON(cookieJson);
    return cookieJson;
}

function extractCookieJson(item) {
    return jQuery.parseJSON(item.replace(/\'/g, "\"").replace("%0a", ""));
}

function parseCustomCookies() {
    var arrCookie = document.getElementById('hdnCookieJson').value.toString().split(";;;");
    for (var i = 0; i < arrCookie.length; i++) {
        var node = arrCookie[i].toString().split("==");
        var key = node[0];
        var val = node[1];
        cookieJson = cookieJson + ",\"" + key + "\":" + JSON.stringify(val) + "";
    }
    cookieJson = "{" + cookieJson.substr(1, cookieJson.length - 1) + "}";
    cookieJson = jQuery.parseJSON(cookieJson);
    return cookieJson;
}

function ConfirmNewEntry() {
    $('input:not(".clsND")[type="submit"][value="New Entry"]').live("click", function () {
        return confirm("Are You Sure for New Entry ?");
    });
    $('input:not(".clsND")[type="submit"][value="Cancel"]').live("click", function () {
        return confirm("Are You Sure to Cancel ?");
    });

    $('input:not(".clsND")[type="button"][value="New Entry"]').live("click", function () {
        return confirm("Are You Sure for New Entry ?");
    });
    $('input:not(".clsND")[type="button"][value="Cancel"]').live("click", function () {
        return confirm("Are You Sure to Cancel ?");
    });

    $.ctrl('N', function () {

        $('input:not(".clsND")[type="submit"][value="New Entry"]').focus();
        $('input:not(".clsND")[type="button"][value="New Entry"]').focus();

        $('input:not(".clsND")[type="submit"][value="New Entry"]').click();
        $('input:not(".clsND")[type="button"][value="New Entry"]').click();

    });
    $.ctrl('S', function () {
        $('input:not(".clsND")[type="submit"][value="Save"]').focus();
        $('input:not(".clsND")[type="button"][value="Save"]').focus();
        window.setTimeout(function () {
            $('input:not(".clsND")[type="submit"][value="Save"]').click();
            $('input:not(".clsND")[type="button"][value="Save"]').click();
        }, 0);


    });
}

ConfirmNewEntry();


function checkDelete(CtrlID, divMsgID, masterTableName, columnName, val, fn) {

    if (fn != undefined && fn != null && fn != "") {
        if (fn() == false) {
            return false;
        }
    }

    if (val == undefined || val == null || val == "" || val == "0") {
        $("#" + divMsgID).msgBox("Please Select a Record to Delete", 1000, "linear", "error", false);
        return false;
    }
    if (document.getElementById(CtrlID).getAttribute("DelValue") != null) {
        if (document.getElementById(CtrlID).getAttribute("DelValue") != "") {
            $("#" + divMsgID).msgBox("Data in use", 1000, "linear", "error", false);
            document.getElementById(CtrlID).removeAttribute("DelValue");
            return false;
        }
        else {
            //alert("Can be deleted...");
            document.getElementById(CtrlID).removeAttribute("DelValue");
            return confirm("Are You Sure to Delete Record...!!!");
        }
    }

    var Params = "'CtrlID':'" + CtrlID + "','masterTableName':'" + masterTableName + "','columnName':'" + columnName + "','columnValue':'" + val + "'";
    CallAjax("form1", "Services/WSDataServices.asmx", "checkDelete", Params, handleCheckDelete, true);

    window.setTimeout("finalResl('" + CtrlID + "','" + divMsgID + "');", 1000);
    return false;
}
function handleCheckDelete(json) {
    var res = jQuery.parseJSON(json.d);
    document.getElementById(res[1]).setAttribute("DelValue", res[0]);
}

function finalResl(ctrl, divMsgID) {
    if (document.getElementById(ctrl).getAttribute("DelValue") != "") {
        $("#" + divMsgID).msgBox("Data in use", 1000, "linear", "error", false);
        document.getElementById(ctrl).removeAttribute("DelValue");
        return false;
    }
    else {
        //$("#" + divMsgID).msgBox("Can be Deleted", 1000, "linear", "success", false);
        document.getElementById(ctrl).click();
        //__doPostBack(ctrl, '');
        //return false;
    }
}

function setCSS() {
    if (document.getElementById('txtCaseCSS')) {
        var link = document.createElement('link');
        var style = document.getElementById('txtCaseCSS').value;
        link.rel = 'stylesheet';
        link.type = 'text/css';
        link.href = '../../App_Themes/default/' + style + '.css';
        //alert(link.href);
        document.getElementsByTagName('head')[0].appendChild(link);
        link = null;
    }
}

//window.setTimeout("setCSS();", 500);

window.onload = function () { setCSS(); }


var SC_Where = '', SC_Having = '', SC_Criteria = '', SC_Othr = '';
var GridLabel = '', GridID = '';
var tabIndex = 0;

function BindSearchNew(ClassName, FunctionName, GridName, GrdID, tbIndex, OthrCondition) {

    GridLabel = GridName;
    GridID = GrdID;
    tabIndex = tbIndex;

    if (OthrCondition == undefined || OthrCondition == null)
        SC_Othr = "";
    else
        SC_Othr = OthrCondition;

    SetConditionAfterSearch();
    return false;

}

function BindSearch(ClassName, FunctionName, GridName, GrdID, tbIndex, OthrCondition) {
    $("#btnSilverSearch").click(function () {
        GridLabel = GridName;
        GridID = GrdID;
        tabIndex = tbIndex;

        if (OthrCondition == undefined || OthrCondition == null)
            SC_Othr = "";
        else
            SC_Othr = OthrCondition;

        SetConditionAfterSearch();
        return false;
    });
}

function SetConditionAfterSearch() {
    var SC_Cond = UCscMakeCondition();
    var key = SC_Cond.split('^');
    SC_Where = key[0];
    SC_Criteria = key[1];
    $("#PrntID").css("display", "block");
    $("#btnPrint").css("display", "block");
    $("#lblFormRepotType").css("display", "block");
    $("#TabContainer").tabs({ selected: tabIndex });
    var JsonParam = "[{\"SC_Criteria\":\"" + SC_Criteria.replace(/'/g, "\\'") + "\",\"SC_Where\":\"" + SC_Where.replace(/'/g, "\\'") + "\",\"OthrCondition\":\"" + SC_Othr.replace(/'/g, "\\'") + "\"}]";
    var Params = " 'param' : '" + JsonParam + "'";
    CallAjax("SearchContainer", "Services/WSDataServices.asmx", "btnSearch", Params, OnSearchSuccess, false);
}

function OnSearchSuccess(result) {
    var res = jQuery.parseJSON(result.d);
    if (res != null) {
        var ucWhere = res.Where[0];
        var ucHaving = res.Having[0];
        var ucOthr = res.OthrCondition[0];
        var ucUserName = res.UserName[0];

        if (ucWhere.length > 0)
            SC_Where = ucWhere.replace(new RegExp(",", "g"), "@splt@");
        else
            SC_Where = SC_Where.replace(new RegExp(",", "g"), "@splt@");

        if (ucHaving.length > 0)
            SC_Having = ucHaving.replace(new RegExp(",", "g"), "@splt@");
        else
            SC_Having = SC_Having.replace(new RegExp(",", "g"), "@splt@");

        if (ucOthr == undefined || ucOthr == null) {
            ucOthr = "";
        }


        $("#" + GridID).html("");
        $("#" + GridID).show();

        if (GridLabel.toLowerCase() == "timetablesubs") 
            var htm = '<object id="PagingGrid" data="data:application/x-silverlight-2," type="application/x-silverlight-2"  width="100%" height="335px"><param name="source" id="source" value="' + ProcessReqUrl("ClientBin/PagingGridSecond.xap") + '" /><param name="onError" value="onSilverlightError" /><param name="background" value="white" /><param name="minRuntimeVersion" value="3.0.40818.0" /><param name="initParams" value="displaygrid=' + GridLabel + ',condition=' + SC_Where + ',having=' + SC_Having + ucOthr + ',username=' + ucUserName + '" /><param name="autoUpgrade" value="true" /><param name="windowless" value="true"/><a href="http://go.microsoft.com/fwlink/?LinkID=149156&v=3.0.40818.0" style="text-decoration: none"><img src="http://go.microsoft.com/fwlink/?LinkId=161376" alt="Get Microsoft Silverlight"style="border-style: none" /></a></object>';
        else
            var htm = '<object id="PagingGrid" data="data:application/x-silverlight-2," type="application/x-silverlight-2"  width="100%" height="335px"><param name="source" id="source" value="' + ProcessReqUrl("ClientBin/PagingGrid.xap") + '" /><param name="onError" value="onSilverlightError" /><param name="background" value="white" /><param name="minRuntimeVersion" value="3.0.40818.0" /><param name="initParams" value="displaygrid=' + GridLabel + ',condition=' + SC_Where + ',having=' + SC_Having + ucOthr + ',username=' + ucUserName + '" /><param name="autoUpgrade" value="true" /><param name="windowless" value="true"/><a href="http://go.microsoft.com/fwlink/?LinkID=149156&v=3.0.40818.0" style="text-decoration: none"><img src="http://go.microsoft.com/fwlink/?LinkId=161376" alt="Get Microsoft Silverlight"style="border-style: none" /></a></object>';

        $("#" + GridID).html(htm);
        $("#TabContainer").tabs({ selected: tabIndex });
    }
}

function AppSetMandatory() {
    var body = $("body");
    var el = $(body).find("input:text[blank='1'][value='']");
    var el1 = $("select[blank='1']");
    var el2 = $(body).find("textarea[blank='1']:empty");
    if (el)
        $(el).css("border", "1px solid red");
    if (el1) {
        for (var i = 0; i < el1.length; i++) {
            if (el1[i].value.indexOf("Select") > -1) {
                $(el1[i]).css("border", "1px solid red");
            }
        }
    }
    if (el2)
        $(el2).css("border", "1px solid red");


}

function AppRemoveMandatory() {
    var body = $("body");
    var el = $(body).find("input:text[blank='1'][value='']");
    var el1 = $(body).find("select[blank='1']");
    var el2 = $(body).find("textarea[blank='1']:empty");
    if (el)
        $(el).css("border", "1px solid silver");
    if (el1)
        $(el1).css("border", "1px solid silver");
    if (el2)
        $(el2).css("border", "1px solid silver");
}

function AppSetMandatory1(container) {
    var body = $("#" + container);
    var el = $(body).find("input:text[blank='1'][value='']");
    var el1 = $("select[blank='1']");
    var el2 = $(body).find("textarea[blank='1']:empty");
    if (el)
        $(el).css("border", "1px solid red");
    if (el1) {
        for (var i = 0; i < el1.length; i++) {
            if (el1[i].value.indexOf("Select") > -1) {
                $(el1[i]).css("border", "1px solid red");
            }
        }
    }
    if (el2)
        $(el2).css("border", "1px solid red");
}

function AppRemoveMandatory1(container) {
    var body = $("#" + container);
    var el = $(body).find("input:text[blank='1'][value='']");
    var el1 = $(body).find("select[blank='1']");
    var el2 = $(body).find("textarea[blank='1']:empty");
    if (el)
        $(el).css("border", "1px solid silver");
    if (el1)
        $(el1).css("border", "1px solid silver");
    if (el2)
        $(el2).css("border", "1px solid silver");
}

function FnEditCancel(container) {

    var IsExist = $('input[type="submit"][value="Save"]');
    if (IsExist.length == 0)
        IsExist = $('input[type="button"][value="Save"]');

    if (IsExist.length == 0) {
        $("#" + container + " :input").attr("disabled", true);

        $("#" + container + " .GridSno").css("visibility", "hidden");
        $("#" + container + " .linkadd").hide();
        AppRemoveMandatory();
    }
    else {
        $("#" + container + " :input").removeAttr("disabled");
        $("#" + container + " .GridSno").css("visibility", "visible");
        $("#" + container + " .linkadd").show();
        AppSetMandatory();
    }

    $('input[type="button"][value="X"]').removeAttr("disabled");

}

function FnEditCancel1(container, id) {

    var IsExist = $("#" + id);
    if (IsExist.length == 0) {
        $("#" + container + " :input").attr("disabled", true);
        $("#" + container + " .GridSno").css("visibility", "hidden");
        $("#" + container + " .linkadd").hide();

        AppRemoveMandatory1(container);
    }
    else {
        $("#" + container + " :input").removeAttr("disabled");
        $("#" + container + " .GridSno").css("visibility", "visible");

        $("#" + container + " .linkadd").show();

        AppSetMandatory1(container);
    }
    $('input[type="button"][value="X"]').removeAttr("disabled");
}

function FnEditCancelByCntr(CntrlIds,idcode,cancelStatus,cancelChk) {

    var IsExist = $('input[type="submit"][value="Save"]');
    if (IsExist.length == 0)
        IsExist = $('input[type="button"][value="Save"]');

   
    if (IsExist.length == 0) {

        for (var col = 0; col < CntrlIds.length; col++) {
            $("#" + CntrlIds[col]).attr("disabled", true);
        }

    }
    else {
        for (var col = 0; col < CntrlIds.length; col++) {
            $("#" + CntrlIds[col]).removeAttr("disabled");
        }
    }

    $('input[type="button"][value="X"]').removeAttr("disabled");


    $("#" + cancelChk).attr("disabled", true);

   // alert($("#" + cancelStatus).val());
    //alert($("#" + idcode).val());
    if (($("#" + cancelStatus).val() != "1" || $("#" + cancelStatus).val() != "Yes" || $("#" + cancelStatus).val() != "Canceled") && $("#" + idcode).val() != "" && $("#" + idcode).val() != "0" && IsExist.length != 0) {
         $("#" + cancelChk).removeAttr("disabled");
    }

 }

 function CheckEditInFee(hcancel, dvMsg) {

     if ($("#" + hcancel).val() == "Yes" || $("#" + hcancel).val() == "1" || $("#" + hcancel).val() == "Canceled") {
         $("#" + dvMsg).html("0/Canceled record could not updated..")
         DisplayMessage(dvMsg);
         return false;
     }
     return true;
 }
