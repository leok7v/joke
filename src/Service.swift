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
    
    static let token: @convention(c) (UnsafePointer<UInt8>?) -> Void = {
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
        file.withCString { cs in
//          print(String(cString: cs))
            service.load(cs)
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
        
    static func fini() {
        service.fini()
    }
}
