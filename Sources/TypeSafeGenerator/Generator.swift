import Foundation

class Generator {
    var parameterMax: Int

    init(max parameters: Int) {
        parameterMax = parameters
    }

    func generate() -> String {
        let permutations = generatePermutations()

        var functions: [Function] = []

        for parameters in permutations {
            if parameters.count == 0 {
                continue
            }

            let function = Function(variant: .socket, method: .get, parameters: parameters)
            functions.append(function)

            for method: Method in [.get, .post, .put, .patch, .delete, .options] {
                let function = Function(variant: .base, method: method, parameters: parameters)
                functions.append(function)
            }
        }

        var generated = [
            warning,
            "import Branches",
            "import HTTP",
            "import Routing",
            "import WebSockets",
            " ",
            "extension RouteBuilder {",
        ]
        for function in functions {
            generated.append(function.description.indented)
        }
        generated.append("}")
        return generated.joined(separator: "\n")
    }

    private func generatePermutations() -> [[Parameter]] {
        var permutations: [[Parameter]] = [[]]

        for i in 0 ... parameterMax {
            var subPermutations: [[Parameter]] = [[]]

            for _ in 0 ..< i {
                subPermutations = permutate(subPermutations)
            }

            permutations += subPermutations
        }
        
        return permutations
    }


    private func permutate(_ array: [[Parameter]]) -> [[Parameter]] {
        var result: [[Parameter]] = []

        for subarray in array {
            var pathArray = subarray
            var wildcardArray = subarray

            let path = Parameter.pathFor(pathArray)
            pathArray.append(path)

            let wildcard = Parameter.wildcardFor(wildcardArray)
            wildcardArray.append(wildcard)

            result.append(pathArray)
            result.append(wildcardArray)
        }
        
        return result
    }

}

extension Generator {
    var warning: String {
        return [
            "/*",
            "    ⚠️ AUTOMATICALLY GENERATED CODE",
            " ",
            "    Generated by Sources/Generator/main.swift.",
            "    Do not edit this file directly.",
            " ",
            "    Last generated: \(NSDate())",
            "*/"
        ].joined(separator: "\n")
    }
}
