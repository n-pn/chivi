<script lang="ts">
  import GdreplTree from './GdreplTree.svelte'
  import GdreplForm from './GdreplForm.svelte'

  export let gdroot = ''
  export let touser = 0
  export let rplist: CV.Rplist

  export let _kind = 'bình luận'

  export let on_new_repl = (new_repl?: CV.Gdrepl) => {
    if (new_repl) {
      rplist.repls ||= []
      rplist.repls.unshift(new_repl)
      rplist = rplist
    }
  }

  function build_tree(repls: CV.Gdrepl[]) {
    const map = new Map<number, CV.Gdrepl>()

    for (const repl of repls) {
      repl.repls ||= []
      map.set(repl.rp_id, repl)
    }

    const output: CV.Gdrepl[] = []

    for (const repl of repls) {
      const parent = map.get(repl.torepl)

      if (parent) parent.repls.push(repl)
      else output.push(repl)
    }

    return output
  }
</script>

<div class="new-repl">
  <GdreplForm
    form={{
      itext: '',
      level: 0,
      gdrepl: 0,
      torepl: 0,
      touser,
      gdroot,
    }}
    placeholder="Thêm {_kind} mới"
    on_destroy={on_new_repl} />
</div>

{#if rplist.repls.length > 0}
  <GdreplTree
    {gdroot}
    repls={build_tree(rplist.repls)}
    level={0}
    fluid={$$props.fluid} />
{:else}
  <div class="u-empty">Chưa có {_kind}</div>
{/if}

<style lang="scss">
  .new-repl {
    display: block;
  }
</style>
