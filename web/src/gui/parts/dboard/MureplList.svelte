<script lang="ts">
  import MureplTree from './MureplTree.svelte'
  import MureplForm from './MureplForm.svelte'

  export let muhead = ''
  export let touser = 0

  export let rplist: CV.Rplist

  export let on_murepl_form = (new_repl?: CV.Murepl) => {
    if (new_repl) {
      rplist.repls ||= []
      rplist.repls.unshift(new_repl)
      rplist = rplist
    }
  }

  function build_tree(repls: CV.Murepl[]) {
    const map = new Map<number, CV.Murepl>()

    for (const repl of repls) {
      repl.repls ||= []
      map.set(repl.id, repl)
    }

    const output: CV.Murepl[] = []

    for (const repl of repls) {
      const parent = map.get(repl.torepl_id)

      if (parent) parent.repls.push(repl)
      else output.push(repl)
    }

    return output
  }
</script>

<div class="new-repl">
  <MureplForm
    form={{
      itext: '',
      level: 0,
      murepl: 0,
      torepl: 0,
      touser,
      muhead,
    }}
    placeholder="Thêm bình luận mới"
    on_destroy={on_murepl_form} />
</div>

{#if rplist.repls.length > 0}
  <MureplTree
    {muhead}
    repls={build_tree(rplist.repls)}
    users={rplist.users}
    memos={rplist.memos}
    level={0}
    fluid={$$props.fluid} />
{:else}
  <div class="empty">Chưa có bình luận</div>
{/if}

<style lang="scss">
  .new-repl {
    display: block;
  }

  .empty {
    @include flex-ca();
    height: 10rem;
    max-height: 30vh;
    font-style: italic;
    @include fgcolor(tert);
  }
</style>
