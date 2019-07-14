//
//  ViewController.swift
//  Surface Detection
//
//  Created by Сергей Калмыков on 7/14/19.
//  Copyright © 2019 Сергей Калмыков. All rights reserved.
//

import ARKit

class ViewController: UIViewController {

    //  MARK: Outlets
    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sceneView.delegate = self
        sceneView.showsStatistics = true
        sceneView.debugOptions = [SCNDebugOptions.showWorldOrigin, SCNDebugOptions.showFeaturePoints]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal]
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
    // MARK: Functions of Work
    private func createFloor(for planeAnchor: ARPlaneAnchor) -> SCNNode {
        let node = SCNNode()
        
        let extent = planeAnchor.extent
        let width = CGFloat(extent.x)
        let height = CGFloat(extent.z)
        
        let geometry = SCNPlane(width: width, height: height)
        geometry.firstMaterial?.diffuse.contents = UIColor.red
        node.geometry = geometry
        node.eulerAngles.x = -.pi/2
        node.opacity = 0.25
        
        return node
    }
    
    private func createShip(planeAnchor: ARPlaneAnchor) -> SCNNode {
        let node = SCNScene(named: "art.scnassets/ship.scn")!.rootNode.clone()
        let center = planeAnchor.center
        node.scale = SCNVector3(0.1, 0.1, 0.1)
        node.position = SCNVector3(center.x, 0, center.z)
        
        return node
    }
}

// MARK: ARSKViewDelegate
extension ViewController: ARSCNViewDelegate {
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor  as? ARPlaneAnchor else { return }
        
        let floor = createFloor(for: planeAnchor)
        node.addChildNode(floor)
        
        let ship = createShip(planeAnchor: planeAnchor)
        node.addChildNode(ship)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor  as? ARPlaneAnchor else { return }
        
        for childNode in node.childNodes {
            let center = planeAnchor.center
            childNode.position = SCNVector3(center.x, 0, center.z)
        }
       
        guard let floor = node.childNodes.first else { return }
        guard let plane = floor.geometry as? SCNPlane else { return }
        
        let extent = planeAnchor.extent
        plane.width = CGFloat(extent.x)
        plane.height = CGFloat(extent.z)
        
        let center = planeAnchor.center
        floor.position = SCNVector3(center.x, 0, center.z)
    }
}
