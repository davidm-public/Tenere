import heronarts.lx.model.*;
import java.util.Collections;
import java.util.List;

LXModel buildTree() {
  return new Hemisphere();
}

// Cheap mockup of the tree canopy until we get a better model
// based upon actual mechanical drawings and fabricated dimensions
public static class Hemisphere extends LXModel {
  
  public static final float NUM_POINTS = 25000;
  public static final float INNER_RADIUS = 33*FEET;
  public static final float OUTER_RADIUS = 36*FEET;
  
  public Hemisphere() {
    super(new Fixture());
  }
  
  private static class Fixture extends LXAbstractFixture {
    Fixture() {
      for (int i = 0; i < NUM_POINTS; ++i) {
        float azimuth = (98752234*i + 4871433);
        float elevation = (i*234.351234) % HALF_PI;
        float radius = INNER_RADIUS + (i * 7*INCHES) % (OUTER_RADIUS - INNER_RADIUS);
        double x = radius * Math.cos(azimuth) * Math.cos(elevation);
        double z = radius * Math.sin(azimuth) * Math.cos(elevation);
        double y = radius * Math.sin(elevation);
        addPoint(new LXPoint(x, y, z));
      }
    }
  }
}

/**
 * Eventually this will be the real tree model. A hierarchical
 * model that represents the modular structure of limbs and
 * assemblages of branches and leaves.
 */
public static class Tree extends LXModel {
  
  public static final float TRUNK_DIAMETER = 3*FEET;
  public static final float LIMB_HEIGHT = 18*FEET;
  public static final int NUM_LIMBS = 12;
  
  public final List<Limb> limbs;
  
  public Tree() {
    this(new LXTransform());
  }
  
  public Tree(LXTransform t) {
    super(new Fixture(t));
    Fixture f = (Fixture) this.fixtures.get(0);
    this.limbs = Collections.unmodifiableList(f.limbs);
  }

  private static class Fixture extends LXAbstractFixture {
    
    private final List<Limb> limbs = new ArrayList<Limb>();
    
    Fixture(LXTransform t) {
      t.translate(0, LIMB_HEIGHT, 0);
      for (int i = 0; i < NUM_LIMBS; ++i) {
        t.push();
        t.rotateX(HALF_PI * i / NUM_LIMBS);
        Limb limb = new Limb(t);
        this.limbs.add(limb);
        addPoints(limb);
        t.pop();
        t.rotateY(TWO_PI / 5);
        
      }
    }
  }
}

/**
 * A limb is a major radial structure coming off the trunk of the
 * tree, which supports many branches.
 */
public static class Limb extends LXModel {
  
  public static final float RADIUS = 16.5*FEET;
  public static final int NUM_BRANCHES = 17;
    
  public final List<Branch> branches;
  
  public Limb(LXTransform t) {
    super(new Fixture(t));
    Fixture f = (Fixture) this.fixtures.get(0);
    this.branches = Collections.unmodifiableList(f.branches);
  }
  
  private static class Fixture extends LXAbstractFixture {
    
    private final List<Branch> branches = new ArrayList<Branch>();
    
    Fixture(LXTransform t) {
      t.push();
      t.translate(0, 0, RADIUS); // move out to the end of the limb
      for (int i = 0; i < NUM_BRANCHES; ++i) {
        t.push();
        
        float azimuth = (float) (-HALF_PI + Math.random() * PI);
        t.rotateY(azimuth);
        float elevation = (float) (HALF_PI - Math.random() * PI/6);
        t.rotateX(elevation);
        t.rotateZ(Math.random() * TWO_PI);
        t.translate(0, 0, (float) Math.random() * 10*INCHES);
        Branch branch = new Branch(t);
        this.branches.add(branch);
        addPoints(branch);
        
        t.pop();
        t.translate(0, 0, -2*INCHES);
      }
      t.pop();
    }
  }
}

/**
 * A branch is mounted on a major limb and houses many
 * leaf assemblages.
 */
public static class Branch extends LXModel {
  public static final int NUM_ASSEMBLAGES = 8;
  public static final float ASSEMBLAGE_RADIUS = 1*FEET;
  
  public static final float LENGTH = 6*FEET;
  public static final float WIDTH = 7*FEET;
  public static final float DEPTH = 1*FEET;
  
  public Branch(LXTransform t) {
    super(new Fixture(t));
  }
  
  private static class Fixture extends LXAbstractFixture {
    
    private final List<Assemblage> assemblages = new ArrayList<Assemblage>();
    
    Fixture(LXTransform t) {
      t.push();
      t.rotateY(-HALF_PI);
      for (int i = 0; i < NUM_ASSEMBLAGES; ++i) {
        t.translate(0, 0, ASSEMBLAGE_RADIUS);
        Assemblage assemblage = new Assemblage(t);
        assemblages.add(assemblage);
        addPoints(assemblage);
        t.translate(0, 0, -ASSEMBLAGE_RADIUS); 
        t.rotateY(PI / NUM_ASSEMBLAGES);
      }
      t.pop();
    }
  }
}

/**
 * An assemblage is a modular fixture with multiple leaves.
 */
public static class Assemblage extends LXModel {
  
  public static final int NUM_LEAVES = 15;

  // x, y, z offset of leaf relative to assemablage base,
  // looking "down" the assemblage goes into the z-axis
  // x axis is left-right offset and y-axis is vertical 
  // TODO(add rotation for geometrically accurate leaves?)  
  public static final PVector[] LEAF_POSITIONS = {    
    new PVector(-4,  0,  0), // 1 - wide leaves at the base
    new PVector( 4,  0,  1), // 2 - wide leaves at the base
    new PVector(-3,  1,  3), // 3
    new PVector( 3, -1,  4), // 4
    new PVector(-3,  0,  6), // 5
    new PVector( 3,  1,  7), // 6
    new PVector(-2,  0,  9), // 7
    new PVector( 2, -1, 10), // 8
    new PVector(-2,  0, 12), // 9
    new PVector( 2,  1, 13), // 10
    new PVector(-1,  1, 15), // 11
    new PVector( 1, -1, 16), // 12
    new PVector(-1,  0, 18), // 13
    new PVector( 1, -1, 19), // 14
    new PVector( 0,  0, 23), // 15 - pointing leaf at the tip
  };

  static {
    // Make sure we didn't bork that array editing manually!
    assert(LEAF_POSITIONS.length == NUM_LEAVES);
  }
  
  public static final float LENGTH = 28*INCHES;
  public static final float WIDTH = 28*INCHES;
  
  public final List<Leaf> leaves;
  
  public Assemblage(LXTransform t) {
    super(new Fixture(t));
    Fixture f = (Fixture) this.fixtures.get(0);
    this.leaves = Collections.unmodifiableList(f.leaves);
  }
  
  private static class Fixture extends LXAbstractFixture {
    
    private final List<Leaf> leaves = new ArrayList<Leaf>();
    
    Fixture(LXTransform t) {
      for (int i = 0; i < NUM_LEAVES; ++i) {
        PVector leafPosition = LEAF_POSITIONS[i];
        t.translate(leafPosition.x*INCHES, leafPosition.y*INCHES, leafPosition.z*INCHES);
        Leaf leaf = new Leaf(t);
        this.leaves.add(leaf);
        addPoints(leaf);
        t.translate(-leafPosition.x*INCHES, -leafPosition.y*INCHES, -leafPosition.z*INCHES);
      }
    }
  }
}

/**
 * The base addressable fixture, a Leaf with LEDs embedded inside.
 * Currently modeled as a single point. Room for improvement!
 */
public static class Leaf extends LXModel {
  public static final int NUM_LEDS = 7;
  public static final float WIDTH = 5*INCHES; 
  public static final float LENGTH = 6.5*INCHES;
  
  public Leaf(LXTransform t) {
    super(new Fixture(t));
  }
  
  private static class Fixture extends LXAbstractFixture {
    Fixture(LXTransform t) {
      // TODO: do we model multiple LEDs here or not?
      addPoint(new LXPoint(t));
    }
  }
}