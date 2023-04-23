<script lang="ts">
  import RpnodeTree from './RpnodeTree.svelte'
  import RpnodeForm from './RpnodeForm.svelte'

  export let rproot = ''
  export let touser = 0

  export let rplist: CV.Rplist

  export let on_rpnode_form = (new_repl?: CV.Rpnode) => {
    if (new_repl) {
      rplist.repls ||= []
      rplist.repls.unshift(new_repl)
      rplist = rplist
    }
  }

  function build_tree(repls: CV.Rpnode[]) {
    const map = new Map<number, CV.Rpnode>()

    for (const repl of repls) {
      repl.repls ||= []
      map.set(repl.id, repl)
    }

    const output: CV.Rpnode[] = []

    for (const repl of repls) {
      const parent = map.get(repl.torepl_id)

      if (parent) parent.repls.push(repl)
      else output.push(repl)
    }

    return output
  }
</script>

<div class="new-repl">
  <RpnodeForm
    form={{
      itext: '',
      level: 0,
      rpnode: 0,
      torepl: 0,
      touser,
      rproot,
    }}
    placeholder="Thêm bình luận mới"
    on_destroy={on_rpnode_form} />
</div>

{#if rplist.repls.length > 0}
  <RpnodeTree
    {rproot}
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
