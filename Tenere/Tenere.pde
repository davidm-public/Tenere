/**
 * Welcome to TÉNÉRÉ! Click the play button in the top left to give it a whirl.
 * The best place to get started with developing is a visit to the "Tutorial" tab.
 * There is code for an example pattern there, which gives some guidance.
 */
 
// Helpful global constants
final static float INCHES = 1;
final static float FEET = 12*INCHES;

// Our engine and our model
LXStudio lx;
LXModel tree;

// Processing's main invocation, build our model and set up LX
void setup() {
  size(1200, 960, P3D);
  tree = buildTree();
  try {
    lx = new LXStudio(this, tree) {
      public void initialize(LXStudio lx, LXStudio.UI ui) {
        lx.registerEffect(DesaturationEffect.class);
        // TODO: the UDP output instantiation will go in here!
      }
      
      public void onUIReady(LXStudio lx, LXStudio.UI ui) {
        ui.preview
          .setRadius(80*FEET)
          .setPhi(-PI/6);
        
        ui.preview.addComponent(new UI3dComponent() {
          @Override
          protected void onDraw(heronarts.p3lx.ui.UI ui, PGraphics pg) {
            // MAJOR IMPROVEMENTS NEEDED HERE!
            // Quick hackup to draw a tree trunk.
            // Let's implement some shaders and have a nice simulation.
            pg.fill(#281403);
            pg.noStroke();
            pg.translate(0, -Tree.LIMB_HEIGHT/2, 0);
            pg.box(Tree.TRUNK_DIAMETER, Tree.LIMB_HEIGHT, Tree.TRUNK_DIAMETER);
            pg.translate(0, Tree.LIMB_HEIGHT/2, 0);
          }
        });
      }
    };
  } catch (Exception x) {
    x.printStackTrace();
  }
}

void draw() {
  // LX handles everything for us!
}

void keyPressed() {
  // Little utility to get a bit of trace info from the engine
  if (key == 'z') {
    lx.engine.logTimers();
  }
}