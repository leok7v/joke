import Foundation

struct Service {

    static var loaded_closure: ((Int32, String) -> Void)?
    static var token_closure: ((String) -> Void)?
    static var done_closure: (() -> Void)?

    static let loaded: @convention(c) (Int32, UnsafePointer<CChar>?) -> Void = {
        err, text in
        guard let cs = text else { return }
        loaded_closure?(err, String(cString: cs))
    }
    
    static let token: @convention(c) (UnsafePointer<CChar>?) -> Void = { 
        token in
        guard let cs = token else { return }
        token_closure?(String(cString: cs))
    }
    
    static let generated: @convention(c) () -> Void = {
        done_closure?()
    }

    static func ini() {
        service.loaded = Service.loaded
        service.token = Service.token
        service.generated = Service.generated
        service.ini()
    }
    
    static func load(file: String,
                     loaded: @escaping (Int32, String) -> Void) {
        loaded_closure = loaded
        file.withCString { cFile in
            service.load(cFile)
        }
    }
    
    static func generate(prompt: String,
                         token: @escaping (String) -> Void,
                         done: @escaping () -> Void) {
        token_closure = token
        done_closure = done
        prompt.withCString { cPrompt in
            service.generate(cPrompt)
        }
    }
    
    static func mirror(input: String) -> (output: String, err: Int32, error: String) {
        var r: Int32 = 0
        var data = Array<UInt8>(repeating: 0, count: input.utf8.count + 1)
        var bytes = Int64(input.utf8.count + 1)
        var output = ""
        var error = ""
        input.withCString { cstr in
            let p = UnsafeRawPointer(cstr).assumingMemoryBound(to: UInt8.self)
            r = service.mirror(p, Int64(input.utf8.count), &data, &bytes)
            if r == 0 {
                output = String(cString: data)
            } else {
                error = String(cString: strerror(r))
            }
        }
        return (output, r, error)
    }
    
    static func fini() {
        service.fini()
    }
}
