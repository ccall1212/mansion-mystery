"""Author the original evidence catalog. No original-game text is consumed."""
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / 'assets/objects'

# identity, title, condition descriptions (initial, detail, repeat), category
ROWS = [
 ('knife', 'Walnut-handled knife', {
  'ordinary': ('A kitchen knife with two brass rivets.', 'The straight blade has an even edge. The walnut grip is firmly attached.', 'The blade and its two-rivet handle look as you remember them.'),
  'bent': ('The tip of a kitchen knife bends sideways.', 'The blade is visibly distorted near its tip. Both handle rivets remain in place.', 'The crooked tip has not changed.')}, 'potential_weapon'),
 ('bust', 'Stone scholar bust', {
  'intact': ('A pale stone scholar watches the room.', 'The carved head rests on a square plinth. Its edges are unbroken.', 'The stone head and square plinth remain intact.'),
  'cracked': ('A crack crosses the scholar’s stone shoulder.', 'A piece is missing from the plinth edge. A dark fracture runs into the shoulder.', 'The missing plinth corner and shoulder fracture are still visible.')}, 'potential_weapon'),
 ('bottle', 'Green champagne bottle', {
  'sealed': ('A green champagne bottle is still corked.', 'Foil covers the neck above a plain cream label. The glass is whole.', 'The cork remains under its foil cap.'),
  'broken': ('A champagne bottle has lost its neck.', 'The broken rim is jagged. Loose green glass lies beside the bottle.', 'The broken neck and scattered fragments remain.')}, 'potential_weapon'),
 ('hammer', 'Joiner’s hammer', {
  'ordinary': ('A steel hammer has a honey-brown handle.', 'The head sits squarely on the wooden shaft. Its striking face is flat.', 'The hammer head remains securely seated.'),
  'damaged': ('The hammer’s wooden handle is splintered.', 'The damaged shaft is still attached to the same dark steel head.', 'The splintered handle would be unsafe to swing.')}, 'potential_weapon'),
 ('stool', 'Oak kitchen stool', {
  'upright': ('A round oak stool stands on four legs.', 'Crossbars brace its legs below the thick circular seat.', 'The round seat and four legs remain upright.'),
  'overturned': ('An oak stool lies on its side.', 'Its four legs and crossbars face outward. The seat is still attached.', 'The same stool remains on its side; that alone explains nothing.')}, 'potential_weapon'),
 ('mirror', 'Brass hand mirror', {
  'intact': ('A small oval mirror has a brass handle.', 'An ornamental frame surrounds unbroken silvered glass.', 'The oval glass remains whole within its frame.'),
  'broken': ('Glass is missing from an oval hand mirror.', 'Jagged glass remains around the brass frame. The handle is unbroken.', 'The gap in the glass is unchanged. Take care around its edges.')}, 'potential_weapon'),
 ('poker', 'Iron fire poker', {
  'straight': ('A long iron poker has a small hooked end.', 'A brass collar joins the dark grip to the straight iron shaft.', 'The straight shaft and hooked tip look unchanged.'),
  'bent': ('An iron fire poker has bowed out of shape.', 'The shaft curves sideways below its hooked tip; the brass collar remains attached.', 'The bowed shaft is still clearly visible.')}, 'potential_weapon'),
 ('magnifier', 'Brass magnifying glass', {
  'ordinary': ('A brass-rimmed magnifying glass rests here.', 'Its clear lens and dark wooden handle look serviceable.', 'The lens is ready for another close examination.')}, 'tool'),
 ('mallet', 'Wooden mallet', {
  'sound': ('A wooden mallet has a broad striking head.', 'The walnut head and its short handle are whole.', 'The mallet still looks serviceable.'),
  'split': ('A split opens through the mallet head.', 'A chipped striking corner exposes the wood beneath its dark finish.', 'The deep split remains open; the handle is still attached.')}, 'potential_weapon'),
 ('decanter', 'Cut-glass decanter', {
  'stoppered': ('A faceted decanter holds a little amber liquid.', 'A round crystal stopper closes the neck above its diamond-cut body.', 'The round stopper is still in place.'),
  'empty': ('An empty decanter stands beside its stopper.', 'The glass has the same cut facets; the stopper has been set aside.', 'The empty vessel and loose stopper remain together.')}, 'household'),
 ('book', 'Bound estate ledger', {
  'whole': ('A burgundy estate ledger lies open.', 'Brass corners protect its cover. A green ribbon marks the unbroken leaves.', 'The ribbon still marks the same spread.'),
  'missing_page': ('A ragged stub interrupts the ledger’s pages.', 'A leaf has been torn from the binding. The burgundy cover and green ribbon remain.', 'The torn page has not been replaced; no text on it can be recovered here.')}, 'potential_weapon'),
 ('safe', 'Cabinet safe', {
  'unmarked': ('A closed iron safe has a brass dial.', 'Its flat door has no obvious dents. The lever remains attached.', 'The closed safe looks undisturbed.'),
  'dented': ('Dents mark the iron door beside its dial.', 'Three impacts and scraped finish interrupt the door surface. They do not tell you when this happened.', 'The dents are unchanged. The door remains closed.')}, 'environment'),
]

FORENSICS = {
 'none': {'tool': 'magnifier', 'description': 'The lens reveals no additional detail worth recording.', 'discovery': '', 'repeat': 'A second look adds nothing to your notes.', 'inset': None},
 'red_trace': {'tool': 'magnifier', 'description': 'Tiny reddish-brown specks lodge beside a handle rivet.', 'discovery': 'Record the specks. Their color alone cannot establish what they are.', 'repeat': 'The specks beside the rivet match your recorded observation.', 'inset': 'res://assets/objects/closeups/detail-red-trace.png'},
 'fiber': {'tool': 'magnifier', 'description': 'A short blue fiber catches in a rough stone edge.', 'discovery': 'Record the trapped fiber without assuming who left it.', 'repeat': 'The blue fiber is still caught at the chipped edge.', 'inset': 'res://assets/objects/closeups/detail-fiber.png'},
 'filings': {'tool': 'magnifier', 'description': 'Pale metallic particles collect along a shallow groove.', 'discovery': 'Record the particles. A comparison with another surface may help later.', 'repeat': 'The same pale particles remain in the groove.', 'inset': 'res://assets/objects/closeups/detail-filings.png'},
}

def build():
    definitions = {}
    for identity, name, variants, category in ROWS:
        conditions = {}
        for condition, (initial, detail, repeat) in variants.items():
            conditions[condition] = {
                'asset': f'res://assets/objects/object-{identity}-{condition}.png',
                'closeup': f'res://assets/objects/closeups/object-{identity}-{condition}.png',
                'initial': initial, 'detailed': detail, 'repeat': repeat, 'overlays': []}
        allowed = ['none']
        if identity == 'knife': allowed += ['red_trace']
        if identity == 'bust': allowed += ['fiber']
        if identity == 'hammer': allowed += ['filings']
        definitions[identity] = {'id': identity, 'name': name, 'category': category,
            'art_status': 'produced', 'base_asset': next(iter(conditions.values()))['asset'],
            'master': f'res://assets/objects/masters/{identity}.png',
            'source_cells': len(conditions), 'anchor': 'bottom_center',
            'conditions': conditions, 'allowed_forensics': allowed,
            'forensic_conditions': {'fiber': ['cracked']} if identity == 'bust' else {},
            'collectible': identity in ['knife', 'mirror', 'magnifier'],
            'examine_in_place': True, 'persistence': ['seen', 'detailed', 'collected', 'magnified', 'discovered']}
    # Authored demonstration placements; no claim that these solve a murder.
    placements = [
        ('foyer-knife', 'knife', 'ordinary', 'red_trace', [152, 256]),
        ('foyer-mirror', 'mirror', 'broken', 'none', [313, 284]),
        ('foyer-lens', 'magnifier', 'ordinary', 'none', [366, 235]),
    ]
    instances = {i: {'id': i, 'definition': d, 'condition': c, 'forensic': f,
                    'room': 'g_foyer', 'position': xy, 'placement': 'floor' if d != 'magnifier' else 'reading stand'}
                 for i, d, c, f, xy in placements}
    for d, condition, forensic in [('bust', 'cracked', 'fiber'), ('bottle', 'sealed', 'none'),
                                  ('hammer', 'ordinary', 'filings'), ('stool', 'overturned', 'none'),
                                  ('poker', 'bent', 'none'), ('mallet','split','none'),
                                  ('decanter','empty','none'), ('book','missing_page','none'),
                                  ('safe','dented','none')]:
        i = 'review-' + d
        instances[i] = {'id': i, 'definition': d, 'condition': condition, 'forensic': forensic,
                        'room': 'evidence_review', 'position': [0, 0], 'placement': 'review only'}
    planned = [
        ('mallet','Wooden mallet','potential_weapon',['sound','split'], 'kitchen'),
        ('candlestick','Brass candlestick','potential_weapon',['straight','bent'], 'dining'),
        ('book','Bound estate ledger','potential_weapon',['whole','missing_page'], 'library'),
        ('paperweight','Veined stone paperweight','potential_weapon',['polished','chipped'], 'study'),
        ('letter_opener','Bone-handled letter opener','potential_weapon',['sound','bent_tip'], 'study'),
        ('statuette','Bronze hound statuette','potential_weapon',['intact','loose_base'], 'hall'),
        ('cane','Ebony walking cane','potential_weapon',['sound','missing_ferrule'], 'foyer'),
        ('doorstop','Cast iron doorstop','potential_weapon',['ordinary','fresh_scrape'], 'hall'),
        ('candelabra','Three-branch candelabra','household',['lit','extinguished'], 'dining'),
        ('decanter','Cut-glass decanter','household',['stoppered','empty'], 'dining'),
        ('oil_lamp','Amber oil lamp','household',['lit','empty'], 'basement'),
        ('hourglass','Walnut hourglass','household',['upright','stopped'], 'library'),
        ('bookend','Stone owl bookend','household',['intact','chipped'], 'library'),
        ('reading_stand','Oak reading stand','household',['empty','open_book'], 'library'),
        ('bowl','Porcelain sweet dish','household',['full','empty'], 'reception'),
        ('ashtray','Ceramic ashtray','household',['clean','used'], 'study'),
        ('pepper_mill','Turned pepper mill','household',['whole','loose_cap'], 'kitchen'),
        ('hairbrush','Silver-backed hairbrush','household',['ordinary','missing_bristles'], 'bedroom'),
        ('picture','Framed landscape','household',['hung','tilted'], 'hall'),
        ('inkstand','Brass desk inkstand','household',['closed','spilled'], 'study'),
        ('vase','Glazed blue vase','household',['whole','missing_shard'], 'reception'),
        ('drawer_pull','Carved drawer pull','household',['attached','detached'], 'bedroom'),
        ('safe','Cabinet safe','environment',['unmarked','dented'], 'study'),
        ('door_lock','Service door lock','environment',['worn','freshly_scored'], 'kitchen'),
        ('telephone','Desk telephone','environment',['connected','cut_cord'], 'study'),
        ('wall_mirror','Hall mirror','environment',['clear','smudged'], 'hall'),
        ('drawer','Writing desk drawer','environment',['empty','foreign_button'], 'study'),
        ('rug','Runner and dust outline','environment',['undisturbed','shifted'], 'hall'),
    ]
    catalog = {'schema_version': 1, 'world_canvas': [32,40], 'inspection_canvas': [160,160],
        'definitions': definitions, 'forensics': FORENSICS, 'instances': instances,
        'expansion_catalog': [{'id': i, 'name': n, 'category': cat, 'proposed_conditions': vs,
            'intended_room': room, 'art_status': 'planned', 'gameplay_ready': False}
            for i,n,cat,vs,room in planned if i not in definitions]}
    (OUT/'object-manifest.json').write_text(json.dumps(catalog, indent=2, ensure_ascii=False)+'\n', encoding='utf-8')
    return catalog

if __name__ == '__main__':
    m=build()
    print(f'{len(m["definitions"])} produced identities, {len(m["expansion_catalog"])} planned catalog entries')
